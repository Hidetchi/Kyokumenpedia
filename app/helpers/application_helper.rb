module ApplicationHelper
  def created_time_ago(model)
    diff = Time.new - model.created_at
    if (diff > 3*365*24*60*60)
      return diff.div(365*24*60*60).to_s + "年前"
    elsif (diff > 2*30*24*60*60)
      return diff.div(30*24*60*60).to_s + "ヶ月前"
    elsif (diff > 24*60*60)
      return diff.div(24*60*60).to_s + "日前"
    elsif (diff > 60*60)
      return diff.div(60*60).to_s + "時間前"
    elsif (diff > 60)
      return diff.div(60).to_s + "分前"
    else
      return diff.to_i.to_s + "秒前"
    end
  end
end
