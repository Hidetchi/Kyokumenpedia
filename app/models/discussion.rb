class Discussion < ActiveRecord::Base
  belongs_to :user
  belongs_to :position
  
  def self.post(hash)
    return if (hash[:content] == "")
    last_post = Discussion.where(position_id: hash[:position_id]).last
    hash[:num] = last_post ? (last_post.num + 1) : 1
    Discussion.create(hash.permit(:user_id, :position_id, :content, :num))
  end
  
  def to_local_time
  	time = self.created_at.localtime
  	time.strftime("%Y/%m/%d　%H時%M分")
  end
end
