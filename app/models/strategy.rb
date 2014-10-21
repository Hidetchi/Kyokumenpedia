class Strategy < ActiveRecord::Base
  has_many :positions
  belongs_to :strategy_group
end
