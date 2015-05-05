class User < ActiveRecord::Base
  ROLE_USER = 0
  ROLE_SUPER_USER = 1
  ROLE_MODERATOR = 2
  ROLE_ADMIN = 3
  ROLE_SUPERVISOR = 4
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  validates_uniqueness_of :username, :case_sensitive => false
  validates :username, length: {minimum: 3, maximum: 32}, format: {with: /\A[a-zA-Z0-9_]+\z/}
  has_many :wikiposts
  has_many :watches
  has_many :watching_positions, :through => :watches, :source => :position
  has_many :following_relations, class_name: 'Follow', foreign_key: 'follower_id'
  has_many :following_users, :through => :following_relations, :source => :followed
  has_many :followed_relations, class_name: 'Follow', foreign_key: 'followed_id'
  has_many :followers, :through => :followed_relations, :source => :follower
  has_many :evaluations, class_name: "ReputationSystem::Evaluation", as: :source
  has_many :notes
  
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
    follow.create_activity(action: 'create', owner: self, recipient: follow.followed) if follow.id
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
#    evaluations.where(target_type: wikipost.class, reputation_name: :likes, target_id: wikipost.id).present?
    evaluations.where(target_id: wikipost.id).present?
  end
  
  def to_rank
    if (self.point == 0)
      return 0
    elsif (self.point < 10)
      return 1
    elsif (self.point < 50)
      return 2
    elsif (self.point < 200)
      return 3
    elsif (self.point < 500)
      return 4
    elsif (self.point < 1000)
      return 5
    else
      return 6
    end
  end
  
  def to_rank_name
    ["一般読者", "編集見習い", "初級エディター", "中級エディター", "上級エディター", "編集長", "局面博士"][self.to_rank]
  end

  def to_role_name
    ["一般", "スーパユーザ", "モデレータ", "管理者", "一般"][self.role]
  end
  
  def to_stars
    tag = ""
    if self.role == ROLE_SUPER_USER
      color = "_blue"
    elsif self.role == ROLE_MODERATOR || self.role == ROLE_ADMIN
      color = "_green"
    else
      color = ""
    end
    self.to_rank.times do
      tag += "<img class='star' src='/assets/star" + color + ".gif'>"
    end
    tag.html_safe
  end

  def can_access_privilege?
    self.role >= ROLE_SUPER_USER && self.role <= ROLE_ADMIN
  end

  def is_admin?
    self.role == ROLE_ADMIN
  end

  def can_select_pro?
    self.role >= ROLE_SUPER_USER
  end

  def can_view_pro?
    self.role >= ROLE_MODERATOR
  end

  def can_issue_card?(user)
    can_access_privilege? && self.role > user.role && user.card != 0 && self.id != user.id
  end
end
