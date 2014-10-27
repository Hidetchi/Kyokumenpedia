class Game < ActiveRecord::Base
  belongs_to :game_source
  belongs_to :handicap
  has_many :appearances, :dependent => :delete_all
  has_many :positions, through: :appearances
  validates :black_name, :white_name, :date, :result, :handicap_id, :game_source_id, presence: true
  
  def self.api_add(params, game_source_id)
    game = Game.new(params)
    game.game_source_id = game_source_id
    begin
      game.save
    rescue
      return nil
    end
    return game
  end
end
