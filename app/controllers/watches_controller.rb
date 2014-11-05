class WatchesController < ApplicationController
  def watch
    @position = current_user.watch(params[:position_id])
    @div_id = params[:div_id]
  end

  def unwatch
    @position = current_user.unwatch(params[:position_id])
    @div_id = params[:div_id]
  end
end
