class DiscussionsController < ApplicationController
  def index
    @position = Position.find_by(id: params[:id])
    @discussions = Discussion.where(:position_id => params[:id]).order('created_at desc')
  end

  def create
    Discussion.post(params[:discussion]) if (params[:discussion])
    redirect_to :action => 'index', :id => params[:discussion][:position_id]
  end
end
