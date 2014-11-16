class ActivitiesController < ApplicationController
  def index
    unless (current_user)
      redirect_to "/positions/start"
      return
    end
    activities_user = Activity.where('owner_id = ? OR (recipient_type = ? AND recipient_id = ?)', current_user.id, 'User', current_user.id).order('created_at desc').limit(50)
    activities_position = Activity.joins(:watchers).where('user_id = ?', current_user.id).order('created_at desc').limit(50)
    @activities = activities_user | activities_position
    @activities.sort_by!{|item| item.created_at}.reverse!
    @positions_count = Position.count
    @games_count = Game.count
    @wikiposts_count = Wikipost.count
  end
end
