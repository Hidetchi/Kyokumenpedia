class UsersController < ApplicationController
  def index
  end

  def show
    @user = User.find(params[:id])
  end

  def watch
    @position = current_user.watch(params[:position_id])
    @div_id = params[:div_id]
    render 'update_watch'
  end

  def unwatch
    @position = current_user.unwatch(params[:position_id])
    @div_id = params[:div_id]
    render 'update_watch'
  end

  def follow
    @user = current_user.follow(params[:user_id])
    @div_id = params[:div_id]
    render 'update_follow'
  end

  def unfollow
    @user = current_user.unfollow(params[:user_id])
    @div_id = params[:div_id]
    render 'update_follow'
  end
end
