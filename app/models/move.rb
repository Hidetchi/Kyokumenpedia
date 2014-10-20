class Move < ActiveRecord::Base
  belongs_to :prev_position, class_name: 'Position', foreign_key: 'prev_position_id'
  belongs_to :next_position, class_name: 'Position', foreign_key: 'next_position_id'
  has_many :appearances
end
