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
      appearance_ids.each do |id|
        Game.delay.update_strategy(id, params[:id])
      end
    end
    redirect_to position_path(params[:position_id])
  end
end
