module UsersHelper
  def watch_button(position, div_id)
    return nil unless current_user
    button_label = position.latest_post_id ? "ウォッチ" : "解説リクエスト"
    if current_user.watching?(position.id)
      button_label += "解除"
      action_name = "unwatch"
      class_name = "toggle off"
    else
      action_name = "watch"
      class_name = "toggle on"
    end
    button_label += " | " + position.watchers.pluck(:id).length.to_s

    button_to button_label, {:controller => 'users', :action => action_name, :position_id => position.id, :div_id => div_id }, :class => class_name, :remote => true
  end

  def follow_button(user, div_id)
    return nil unless current_user
    button_label = "フォロー"
    if current_user.following?(user.id)
      button_label += "解除"
      action_name = "unfollow"
      class_name = "toggle off"
    else
      button_label += "する"
      action_name = "follow"
      class_name = "toggle on"
    end
    button_label += " | " + user.followed_relations.pluck(:id).length.to_s

    button_to button_label, {:controller => 'users', :action => action_name, :user_id => user.id, :div_id => div_id }, :class => class_name, :remote => true
  end
  
  def like_button(wikipost)
    return nil unless current_user
    if current_user.liked?(wikipost)
      action_name = "like"
      class_name = "toggle off"
    else
      action_name = "like"
      class_name = "toggle on"
    end
    button_label = "いいね! | " + wikipost.reputation_for(:likes).to_i.to_s

    button_to button_label, {:controller => 'users', :action => action_name, :wikipost_id => wikipost.id }, :class => class_name, :remote => true
  end
end
