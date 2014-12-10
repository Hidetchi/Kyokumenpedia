class StrategiesController < ApplicationController
  def index
    raise UserException::AccessDenied unless (current_user && current_user.can_access_strategy?)
    @position = Position.find(params[:position_id])
    @root_strategies = Strategy.where(ancestry: nil)
  end

  def create
    raise UserException::AccessDenied unless (current_user && current_user.is_admin?)
    if (parent = Strategy.find(params[:strategy][:parent_id]))
      parent.children.create(:name => params[:strategy][:name])
    end
    index
    render 'index'
  end

  def update
    raise UserException::AccessDenied unless (current_user && current_user.can_access_strategy?)
    if ((position = Position.find(params[:position_id])) && (strategy = Strategy.find(params[:id])))
      overwrite_following_positions(position, strategy, strategy.descendant_ids)
    end
    redirect_to position_path(params[:position_id])
  end

  private
  def overwrite_following_positions(position, strategy, descendant_ids)
    position.overwrite_strategy(strategy)
    position.next_positions.each do |next_position|
      overwrite_following_positions(next_position, strategy, descendant_ids) unless (strategy.id == next_position.strategy_id || descendant_ids.include?(next_position.strategy_id))
    end
  end
end
