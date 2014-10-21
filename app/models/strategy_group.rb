class StrategyGroup < ActiveRecord::Base
  has_many :strategies
  belongs_to :strategy_family
end
