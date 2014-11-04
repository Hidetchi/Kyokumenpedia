class WatchesController < ApplicationController
  def watch
    @watch = Watch.create(params.permit(:user_id, :position_id))
    @div_id = params[:div_id]
    @position = @watch.position
  end

  def unwatch
    if (@watch = Watch.includes(:user).find_by(params.permit(:user_id, :position_id)))
      @position = @watch.position
      @watch.destroy
    else
      @position = Position.find(params[:position_id])
    end
    @div_id = params[:div_id]
  end
end
