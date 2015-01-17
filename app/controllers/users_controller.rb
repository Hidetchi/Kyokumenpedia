class UsersController < ApplicationController
  before_action :authenticate_user!, :only => [:mypage]
  
  def index
  end
  
  def ranking
    @users = User.order('point desc').limit(30)
  end
  
  def update
    if (current_user)
      params[:user][:strength] = cut_length(params[:user][:strength], 40)
      params[:user][:style] = cut_length(params[:user][:style], 40)
      params[:user][:description] = cut_length(params[:user][:description], 140)
      params[:user][:url] = "" if (!params[:user][:url].match(/\Ahttps?:\/\/.+\z/))
      params[:user][:name81] = "" if (!params[:user][:name81].match(/\A[a-zA-Z0-9_]{3,32}\z/))
      @user = current_user
      @user.update_attributes(params[:user].permit(:strength, :style, :url, :description, :name81, :receive_watching, :receive_following))
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
    @div_id = params[:div_id]
    render 'update_like'
  end

  def card
    raise UserException::AccessDenied unless (current_user && current_user.can_access_privilege?)
    @user = User.find(params[:id])
    was_blocked = (@user.card == 1 || @user.card == 4)
    @user.update_attributes(card: params[:color].to_i)
    Feeder.card_removed(@user, true).deliver if (was_blocked && @user.card == 0)
    Feeder.card_removed(@user, false).deliver if (was_blocked && @user.card == 2)
    redirect_to user_path(@user.id)
  end

  protected
  def cut_length(str, len)
    str = str[0..(len-1)] if str.length > len
    str
  end
end
