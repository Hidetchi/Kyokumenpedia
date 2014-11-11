class UsersController < ApplicationController
  before_action :authenticate_user!, :only => [:mypage]
  
  def index
  end
  
  def update
    if (current_user)
      @user = current_user
      @user.update_attributes(params[:user].permit(:strength, :style, :url, :description, :name81))
    end
    render 'show'
  end

  def show
    @user = User.find(params[:id])
  end
  
  def mypage
    @user = current_user
    render 'show'
  end
  
  def followers
    @user = User.find(params[:id])
    @followers = @user.followers
  end

  def watch
    @position = current_user.watch(params[:position_id]) if (current_user)
    @div_id = params[:div_id]
    render 'update_watch'
  end

  def unwatch
    @position = current_user.unwatch(params[:position_id]) if (current_user)
    @div_id = params[:div_id]
    render 'update_watch'
  end

  def follow
    @user = current_user.follow(params[:user_id]) if (current_user)
    @div_id = params[:div_id]
    render 'update_follow'
  end

  def unfollow
    @user = current_user.unfollow(params[:user_id]) if (current_user)
    @div_id = params[:div_id]
    render 'update_follow'
  end
  
  def like
    @wikipost = Wikipost.find(params[:wikipost_id])
    @wikipost.like(current_user) if (current_user)
    render 'update_like'
  end
end
