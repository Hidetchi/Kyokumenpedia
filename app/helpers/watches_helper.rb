module WatchesHelper
  def watch_button(user, position, div_id)
    button_label = position.latest_post_id ? "ウォッチ" : "解説リクエスト"
    if user.watching?(position.id)
      button_label += "解除"
      action_name = "unwatch"
      class_name = "toggle off"
    else
      action_name = "watch"
      class_name = "toggle on"
    end
    button_label += " | " + position.watchers.pluck(:id).length.to_s

    button_to button_label, {:controller => 'watches', :action => action_name, :user_id => user.id, :position_id => position.id, :div_id => div_id }, :class => class_name, :remote => true
  end
end
