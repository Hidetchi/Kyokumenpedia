class ActivitiesController < ApplicationController
  def index
    unless (current_user)
      redirect_to "/positions/start"
      return
    end
    activities_self = Activity.includes(:owner).includes(:recipient).includes(:trackable).where('owner_id = ? OR (recipient_type = ? AND recipient_id = ?)', current_user.id, 'User', current_user.id).order('created_at desc').limit(15)
    activities_follow = Activity.includes(:owner).includes(:recipient).includes(:trackable).joins(:followers).where('NOT trackable_type = "Follow" AND follower_id = ?', current_user.id).order('created_at desc').limit(30)
    activities_position = Activity.includes(:owner).includes(:recipient).includes(:trackable).joins(:watchers).where('user_id = ?', current_user.id).order('created_at desc').limit(30)
    @activities = activities_self | activities_follow | activities_position
    @activities.sort_by!{|item| item.created_at}.reverse!
    @positions_count = Position.count
    @games_count = Game.count
    @wikiposts_count = Wikipost.count
  end
end
