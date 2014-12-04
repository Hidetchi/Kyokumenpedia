class Appearance < ActiveRecord::Base
  belongs_to :game
  belongs_to :position
  belongs_to :next_move, :class_name => 'Move', :foreign_key => 'next_move_id'
  validates :game, :uniqueness => {:scope => :position}
end
