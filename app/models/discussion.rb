class Discussion < ActiveRecord::Base
  belongs_to :user
  belongs_to :position
  
  def self.post(hash)
    return if (hash[:content] == "")
    last_post = Discussion.where(position_id: hash[:position_id]).last
    hash[:num] = last_post ? (last_post.num + 1) : 1
    discussion = Discussion.create(hash.permit(:user_id, :position_id, :content, :num))
    if (!last_post || ((Time.now - last_post.created_at) > 60*60*24))
      discussion.position.watchers.each do |watcher|
        Feeder.delay.discussion_to_watcher(watcher.id, discussion.id)
      end
    end
  end
  
  def to_local_time
  	time = self.created_at.localtime
  	time.strftime("%Y/%m/%d　%H時%M分")
  end
end
