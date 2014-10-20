class Handicap < ActiveRecord::Base
  has_many :games
  has_many :positions
end
