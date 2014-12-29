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
    # Update relations between positions, moves, etc in background
    Game.delay.update_relations(game.id) if analysis_job
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
        positions[i].appearances.build(:game_id => game.id, :num => i, :next_move_id => move.id)
        positions[i].update_stat(game.game_source.category, game.result)
        position_already[sfens[i]] = true
      end
    end
    game.update_attributes(:relation_updated => true)
    
    end #transaction-end
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
    player_name = player_name[0..13] + "..." if player_name.length > 15
    if (category == 2 && !user)
      "???"
    else
      player_name
    end
  end

  def show_kifu?(user, category)
    self.native_kid && (category == 3 || (category == 2 && user) || (category == 1 && user && user.is_admin?))
  end
end
