class PosReference < ActiveRecord::Base
  belongs_to :referrer, class_name: 'Position', foreign_key: 'referrer_id'
  belongs_to :referred, class_name: 'Position', foreign_key: 'referred_id'
end
