class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,# :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  validates_uniqueness_of :username, :case_sensitive => false
  validates :username, length: {minimum: 3}
  has_many :watches
  has_many :watching_positions, :through => :watches, :source => :position
  
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
end
