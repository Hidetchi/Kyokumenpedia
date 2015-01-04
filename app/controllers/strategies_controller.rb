class StrategiesController < ApplicationController
  def create
    raise UserException::AccessDenied unless (current_user && current_user.is_admin?)
    if (parent = Strategy.find(params[:strategy][:parent_id]))
      parent.children.create(:name => params[:strategy][:name])
    end
    index
    render 'index'
  end

  def update
    raise UserException::AccessDenied unless (current_user && current_user.can_access_privilege?)
    position = Position.find(params[:position_id])
    appearance_ids = position.appearances.pluck(:id)
    appearance_ids.each do |id|
      Game.delay.update_strategy(id, params[:id])
    end
    redirect_to position_path(params[:position_id])
  end
end
