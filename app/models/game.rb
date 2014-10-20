class Game < ActiveRecord::Base
  belongs_to :game_source
  belongs_to :handicap
  has_many :appearances, :dependent => :delete_all
  has_many :positions, through: :appearances
  validates :black_name, :white_name, :date, :result, :handicap_id, :game_source_id, presence: true
end
