class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :note

  def to_local_time
  	time = self.created_at.localtime
  	time.strftime("%Y/%m/%d　%H時%M分")
  end
end
