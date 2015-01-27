class DiscussionsController < ApplicationController
  before_action :authenticate_user!, :only => [:post]

  def index
    @position = Position.find_by(id: params[:position_id])
    @discussions = Discussion.where(:position_id => params[:position_id]).includes(:user).order('created_at desc')
  end
  
  def post
    index
    render 'index'
  end

  def create
    raise UserException::AccessDenied if (current_user.card == 5)
    if (params[:discussion])
      params[:discussion][:user_id] = current_user.id
      params[:discussion][:position_id] = params[:position_id]
      Discussion.post(params[:discussion])
    end
    redirect_to position_discussions_path(params[:position_id])
  end

  def recent
    ids = Discussion.group(:position_id).order('max(id) desc').pluck('max(id)')
    ids = ids[0..49] if ids.length > 50
    @discussions = Discussion.includes(:position => :strategy).includes(:user).where(id: ids).order('id desc')
  end
end
