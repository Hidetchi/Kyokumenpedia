class DiscussionsController < ApplicationController
  before_action :authenticate_user!, :only => [:post]

  def index
    @position = Position.find_by(id: params[:id])
    @discussions = Discussion.where(:position_id => params[:id]).includes(:user).order('created_at desc')
  end
  
  def post
    index
    render 'index'
  end

  def create
    if (params[:discussion])
      params[:discussion][:user_id] = current_user.id
      Discussion.post(params[:discussion])
    end
    redirect_to :action => 'index', :id => params[:discussion][:position_id]
  end
end
