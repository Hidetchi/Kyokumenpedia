class Strategy < ActiveRecord::Base
  has_many :positions
  has_ancestry
end
