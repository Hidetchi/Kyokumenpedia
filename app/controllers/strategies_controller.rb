class StrategiesController < ApplicationController
  def create
    raise UserException::AccessDenied unless (current_user && current_user.is_admin?)
    if (parent = Strategy.find(params[:strategy][:parent_id]))
      parent.children.create(:name => params[:strategy][:name])
    end
    expire_fragment('strategy_tree')
    redirect_to search_positions_path
  end

  def update
    raise UserException::AccessDenied unless (current_user && current_user.can_access_privilege?)
    position = Position.find(params[:position_id])
    appearance_ids = position.appearances.pluck(:id)
    if (appearance_ids.length < 1)
      position.update_strategy(Strategy.find(params[:id]), true)
    else
      mode = session[:update_strategy_mode] || 0
      session[:update_strategy_mode] = 0
      appearance_ids.each do |id|
        Game.delay.update_strategy(id, params[:id].to_i, mode)
      end
    end
    redirect_to position_path(params[:position_id])
  end

  def mode
    if (params[:mode] == nil || params[:mode].to_i == 0)
      session[:update_strategy_mode] = 0
    elsif (params[:mode].to_i == 1)
      session[:update_strategy_mode] = 1
    elsif (params[:mode].to_i == 2)
      session[:update_strategy_mode] = 2
    else
      session[:update_strategy_mode] = 0
    end
    render :nothing => true
  end
end
