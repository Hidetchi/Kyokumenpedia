class Game < ActiveRecord::Base
  belongs_to :game_source
  belongs_to :handicap
  has_many :appearances, :dependent => :delete_all
  has_many :positions, through: :appearances
  validates :black_name, :white_name, :date, :result, :handicap_id, :game_source_id, presence: true
  
  def self.api_add(params, game_source_id)
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
