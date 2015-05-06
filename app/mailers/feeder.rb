class Feeder < ActionMailer::Base
  add_template_helper(NotesHelper)
  default from: "info@kyokumen.jp"
  SUBJECT_HEADER = "【" + SITE_NAME + "】"
  
  def wikipost_to_watcher(recipient_id, wikipost_id)
    @recipient = User.find(recipient_id)
    @wikipost = Wikipost.find(wikipost_id)
    mail to: @recipient.email, subject: SUBJECT_HEADER + "ウォッチ中の局面の解説が編集されました"
  end
  
  def wikipost_to_follower(recipient_id, wikipost_id)
    @recipient = User.find(recipient_id)
    @wikipost = Wikipost.find(wikipost_id)
    mail to: @recipient.email, subject: SUBJECT_HEADER + "フォロー中の" + @wikipost.user.username + "さんが局面の解説を編集しました"
  end
  
  def discussion_to_watcher(recipient_id, discussion_id)
    @recipient = User.find(recipient_id)
    @discussion = Discussion.find(discussion_id)
    mail to: @recipient.email, subject: SUBJECT_HEADER + "ウォッチ中の局面のディスカッションが投稿されました"
  end

  def note_to_watcher(recipient_id, note_id)
    @recipient = User.find(recipient_id)
    @note = Note.find(note_id)
    mail to: @recipient.email, subject: SUBJECT_HEADER + "ウォッチ中の局面の公開マイノートが作成されました"
  end

  def note_to_follower(recipient_id, note_id)
    @recipient = User.find(recipient_id)
    @note = Note.find(note_id)
    mail to: @recipient.email, subject: SUBJECT_HEADER + "フォロー中の" + @note.user.username + "さんが公開マイノートを作成しました"
  end

  def notify_comment(recipient_id, comment_id)
    @recipient = User.find(recipient_id)
    @comment = Comment.find(comment_id)
    mail to: @recipient.email, subject: SUBJECT_HEADER + @comment.user.username + "さんが公開マイノートにコメントを投稿しました"
  end

  def card_removed(recipient)
    @recipient = recipient
    mail to: @recipient.email, subject: SUBJECT_HEADER + "ブルーカードが解除されました"
  end
end
