class Feeder < ActionMailer::Base
  default from: "kyokumenpedia@iscube.com"
  SUBJECT_HEADER = "【" + SITE_NAME + "】"
  
  def wikipost_to_watcher(recipient_id, wikipost_id)
    @recipient = User.find(recipient_id)
    @wikipost = Wikipost.find(wikipost_id)
    mail to: @recipient.email, subject: SUBJECT_HEADER + "ウォッチ中の局面の解説が編集されました"
  end
  
  def wikipost_to_follower(recipient_id, wikipost_id)
    @recipient = User.find(recipient_id)
    @wikipost = Wikipost.find(wikipost_id)
    mail to: @recipient.email, subject: SUBJECT_HEADER + @wikipost.user.username + "さんが局面の解説を編集しました"
  end
  
  def discussion_to_watcher(recipient_id, discussion_id)
    @recipient = User.find(recipient_id)
    @discussion = Discussion.find(discussion_id)
    mail to: @recipient.email, subject: SUBJECT_HEADER + "ウォッチ中の局面のディスカッションが投稿されました"
  end
end
