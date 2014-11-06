class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,# :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  validates_uniqueness_of :username, :case_sensitive => false
  validates :username, length: {minimum: 3}
  has_many :wikiposts
  has_many :watches
  has_many :watching_positions, :through => :watches, :source => :position
  has_many :following_relations, class_name: 'Follow', foreign_key: 'follower_id'
  has_many :following_users, :through => :following_relations, :source => :followed
  has_many :followed_relations, class_name: 'Follow', foreign_key: 'followed_id'
  has_many :evaluations, class_name: "ReputationSystem::Evaluation", as: :source
  
  def watching?(position_id)
    self.watches.pluck(:position_id).include?(position_id)
  end
  
  def watch(position_id)
    watch = self.watches.create(:position_id => position_id)
    watch.position
  end

  def unwatch(position_id)
    if (watch = self.watches.find_by(:position_id => position_id))
      position = watch.position
      watch.destroy
      position
    else
      Position.find_by(:id => position_id)
    end
  end
  
  def following?(user_id)
    self.following_relations.pluck(:followed_id).include?(user_id)
  end
  
  def follow(user_id)
    follow = self.following_relations.create(:followed_id => user_id)
    follow.followed
  end

  def unfollow(user_id)
    if (follow = self.following_relations.find_by(:followed_id => user_id))
      user = follow.followed
      follow.destroy
      user
    else
      User.find_by(:id => user_id)
    end
  end  
  
  def liked?(wikipost)
    evaluations.where(target_type: wikipost.class, reputation_name: :likes, target_id: wikipost.id).present?
  end
end
