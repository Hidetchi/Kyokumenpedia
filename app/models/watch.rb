class Watch < ActiveRecord::Base
  belongs_to :user
  belongs_to :position
  
  validates :position, :uniqueness => {:scope => :user}
end
