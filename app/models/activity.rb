class Activity < PublicActivity::Activity
  belongs_to :position, -> { where(activities: {recipient_type: 'Position'}) }, foreign_key: 'recipient_id'
  has_many :watchers, through: :position, source: :watchers
end
