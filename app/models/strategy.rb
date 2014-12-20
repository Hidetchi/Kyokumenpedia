class Strategy < ActiveRecord::Base
  has_many :positions
  belongs_to :main_position, class_name: 'Position', foreign_key: 'main_position_id'
  has_ancestry
end
