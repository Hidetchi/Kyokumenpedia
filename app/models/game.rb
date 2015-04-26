class Game < ActiveRecord::Base
  belongs_to :game_source
  belongs_to :handicap
  has_many :appearances, :dependent => :delete_all
  has_many :positions, through: :appearances
  validates :black_name, :white_name, :date, :result, :handicap_id, :game_source_id, presence: true
  
  def self.insert_with_hash(params, game_source_id)
    game = Game.new(params)
    game.game_source_id = game_source_id
    game.csa_hash = Digest::MD5.hexdigest(game.csa)
    begin
      game.save
    rescue
      return nil
    end
    return game
  end
 
  def self.save_after_validation(params, analysis_job = false)
    # Check game source password. Give error if invalid. Any trusted kifu provider can post kifu (for example 81Dojo) with its unique password.
    unless (game_source = GameSource.find_by(pass: params[:game_source_pass]))
      return {:result => 'Authentication failed. Access info has been logged.'}
    end
    # Check handicap code. Give error if invalid. 1: even 2: lance-handicap 3: 4: 5: ...... 9: 8-piece-handicap
    unless (handicap = Handicap.find_by(id: params[:handicap_id]))
      return {:result => 'No proper handicap specified.'}
    end

    #TODO ここの一連の処理をどこか別の場所でもみたので処理を共通化するといいと思います
    # parse moves from the continuous CSA move string
    csa_moves = []
    rs = params[:csa].gsub %r{[\+\-]\d{4}\w{2}} do |s|
      csa_moves << s
      ""
    end
    if !rs.empty?
      return {:result => 'Invalid moves.'} unless (rs == '%TORYO')
      csa_moves << rs
    end
    return {:result => 'No moves specified'} if csa_moves.empty?
    
    board = Board.new
    board.initial(params[:handicap_id].to_i)

    sfens = [] # sfen for each move
    sfens << board.to_sfen
    rt = nil
    csa_moves.each do |csa_move|
      # if there is a move when sennichite has been already output
      return {:result => 'Additional move after sennichite.'} if (rt == :sennichite)
      rt = board.handle_one_move(csa_move)
      unless (rt == :normal || rt == :toryo || rt == :sennichite)  # any other output than these indicate illegal move etc.
        return {:result => 'Illegal move ' + csa_move}
      end
      sfens << board.to_sfen unless rt == :toryo
    end
    if (game_source.category != 4)
      # if there is no result output even after the last move, it's invalid
      return {:result => 'No result'} if (rt == :normal)
      if (rt == :sennichite)
        result_code = 2
      else
        result_code = board.teban ? 1 : 0
      end
      # when the result does not match
      return {:result => 'Result does not match'} if (params[:result].to_i != result_code)
      winner = (result_code == 0 ? "Sente" : (result_code == 1 ? "Gote" : "Draw"))
      # If the kifu is OK, then save the game to record
      unless (game = Game.insert_with_hash(params.permit(:black_name, :white_name, :date, :csa, :result, :handicap_id, :native_kid, :event), game_source.id))
        return {:result => 'Duplicate Kifu'}
      end
      return {:result => 'Unknown error'} if (!game.id)
      # Update relations between positions, moves, etc in background
      Game.delay.update_relations(game.id) if analysis_job
    else
      winner = 2
      positions = []
      ActiveRecord::Base.transaction do
        strategy = nil
        for i in 0..(sfens.length - 1) do
          positions << Position.find_or_create(sfens[i])
        end
        for i in 0..(positions.length - 1) do
          move = Move.find_or_new(positions[i].id, positions[i+1].id, csa_moves[i], true) if (i < positions.length - 1)
          strategy = positions[i].update_strategy(strategy)
          positions[i].appearances.create(num: i) if positions[i].appearances.count == 0
        end
      end #transaction-end
    end
    response=Hash[
      result: "Success",
      moves: sfens.length,
      winner: winner,
      positions: sfens,
      player_sente: params[:black_name],
      player_gote: params[:white_name],
      date: params[:date],
      handicap: handicap.name,
      identification: game_source.name
      ]
    return response
  end

  def self.update_relations(game_id)
    game = self.find(game_id)
    return if game.relation_updated
    # There is no validation of csa moves anymore as it is already validated in GamesController#create
    csa_moves = []
    rs = game.csa.gsub %r{[\+\-]\d{4}\w{2}} do |s|
      csa_moves << s
      ""
    end
    csa_moves << rs if !rs.empty?
    board = Board.new
    board.initial(game.handicap_id)
    sfens = [] # sfen for each move
    positions = [] # Position models
    sfens << board.to_sfen
    csa_moves.each do |csa_move|
      board.handle_one_move(csa_move)
      sfens << board.to_sfen
    end
    
    ActiveRecord::Base.transaction do

    strategy = nil
    for i in 0..(sfens.length - 1) do
      positions << Position.find_or_create(sfens[i])
    end
    position_already = Hash::new(false)
    move_already = Hash::new(false)

    for i in 0..(positions.length - 1) do
      unless (i >= positions.length - 1)
        move = Move.find_or_new(positions[i].id, positions[i+1].id, csa_moves[i])
        unless move_already[sfens[i]+sfens[i+1]]
          move.update_stat(game.game_source.category)
          move_already[sfens[i]+sfens[i+1]] = true
        end
      end
      unless position_already[sfens[i]]
        strategy = positions[i].update_strategy(strategy)
        ActiveRecord::Base.connection.execute("INSERT INTO `appearances` (`game_id`, `next_move_id`, `num`, `position_id`) VALUES (#{game.id}, #{move.id}, #{i}, #{positions[i].id})")
        positions[i].update_stat(game.game_source.category, game.result)
        position_already[sfens[i]] = true
      end
    end
    game.update_attributes(:relation_updated => true)
    
    end #transaction-end
  end
  
  def self.update_strategy(appearance_id, strategy_id, level = 0)
    # level = 0: Soft: Update only if position.strategy == nil, otherwise break
    # level = 1: Middle: Update only if position.strategy is not family of new strategy, otherwise break
    # level = 2: Hard: Update only if position.strategy is not family of new strategy, and keep going to the end
    appearance = Appearance.find(appearance_id)
    game = appearance.game
    strategy = Strategy.find(strategy_id)

    csa_moves = []
    rs = game.csa.gsub %r{[\+\-]\d{4}\w{2}} do |s|
      csa_moves << s
      ""
    end
    board = Board.new
    board.initial(game.handicap_id)
    sfens = [] # sfen for each move
    sfens << board.to_sfen
    csa_moves.each do |csa_move|
      board.handle_one_move(csa_move)
      sfens << board.to_sfen
    end
    
    ActiveRecord::Base.transaction do
      for i in appearance.num..(sfens.length - 1) do
        position = Position.find_by(sfen: sfens[i])
        if (level == 0)
          break unless (position.strategy_id == nil || position.strategy_id == strategy_id)
        elsif (level == 1)
          break if strategy.id != strategy_id
        end
        strategy = position.update_strategy(strategy, true) # Hard-mode: ON
      end
    end
  end

  def ci_error_fix(position_id)
    appearances = self.appearances.where(position_id: position_id)
    return "Could not find specified duplicate appearances" if appearances.count != 2
    app1 = appearances.first
    app2 = appearances.last
    n1 = app1.num
    n2 = app2.num

    csa_moves = []
    rs = self.csa.gsub %r{[\+\-]\d{4}\w{2}} do |s|
      csa_moves << s
      ""
    end
    board = Board.new
    board.initial(self.handicap_id)
    sfens = [] # sfen for each move
    sfens << board.to_sfen
    csa_moves.each do |csa_move|
      board.handle_one_move(csa_move)
      sfens << board.to_sfen
    end
    
    ActiveRecord::Base.transaction do

      pos2 = Position.find_or_create(sfens[n2])
      app2.update_attributes(position_id: pos2.id)
      pos2.update_stat(self.game_source.category, self.result)

      prev_pos = Position.find_by(sfen: sfens[n2-1])
      next_pos = Position.find_by(sfen: sfens[n2+1])
      prev_move = Move.find_by(prev_position_id: prev_pos.id, next_position_id: position_id)
      next_move = Move.find_by(prev_position_id: position_id, next_position_id: next_pos.id)

      return "prev_move stat is Zero!" if prev_move["stat" + self.game_source.category.to_s + "_total"] == 0
      prev_move["stat" + self.game_source.category.to_s + "_total"] -= 1
      prev_move.save
      prev_move.destroy if (prev_move.stat1_total + prev_move.stat2_total + prev_move.stat3_total == 0)
      
      move = Move.find_or_new(prev_pos.id, pos2.id, csa_moves[n2-1])
      move.update_stat(self.game_source.category)
      self.appearances.find_by(position_id: prev_pos.id).update_attributes(next_move_id: move.id)

      return "next_move stat is Zero!" if next_move["stat" + self.game_source.category.to_s + "_total"] == 0
      next_move["stat" + self.game_source.category.to_s + "_total"] -= 1
      next_move.save
      next_move.destroy if (next_move.stat1_total + next_move.stat2_total + next_move.stat3_total == 0)

      move = Move.find_or_new(pos2.id, next_pos.id, csa_moves[n2])
      move.update_stat(self.game_source.category)
      app2.update_attributes(next_move_id: move.id)

    end
    return "OK"
  end

  def to_result_mark(sente)
    if (self.result == 0)
      sente ? "○" : "●"
    elsif (self.result == 1)
      sente ? "●" : "○"
    else
      "△"
    end
  end      

  def render_player_name(user, category, sente)
    player_name = sente ? self.black_name : self.white_name
    player_name = player_name[0..10] + "..." if player_name.length > 12
    if (category == 2 && !user)
      "<span class='dark_red'>???</span>".html_safe
    else
      player_name
    end
  end

  def render_event
    return nil if !self.event
    self.event.length > 12 ? (self.event[0..10] + "...") : self.event
  end

  def show_kifu?(user, category)
    self.native_kid && (category == 3 || (category == 2 && user) || (category == 1 && user && user.can_view_pro?))
  end
end
