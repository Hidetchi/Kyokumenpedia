class Activity < PublicActivity::Activity
  belongs_to :position, -> { where(activities: {recipient_type: 'Position'}) }, foreign_key: 'recipient_id'
  has_many :watchers, through: :position, source: :watchers
  belongs_to :actor, -> { where(activities: {owner_type: 'User'}) }, class_name: 'User', foreign_key: 'owner_id'
  has_many :followers, through: :actor, source: :followers
end
