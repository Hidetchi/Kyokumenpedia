class Follow < ActiveRecord::Base
  belongs_to :follower, class_name: 'User', foreign_key: 'follower_id'
  belongs_to :followed, class_name: 'User', foreign_key: 'followed_id'
  
  validates :followed, :uniqueness => {:scope => :follower}
end
