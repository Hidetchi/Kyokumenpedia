require 'board'
class WikipostsController < ApplicationController

  def index
    if (params[:position_id])
      @wikiposts = Wikipost.where(:position_id => params[:position_id])
    elsif (params[:user_id])
      @wikiposts = Wikipost.where(:user_id => params[:user_id])
    end
  end
  
  def show
    @wikipost = Wikipost.find_by(id: params[:id])
  end

  def create
    if (params[:preview])
      redirect_to '/positions/' + params[:wikipost][:position_id] + '/edit?content=' + ERB::Util.url_encode(params[:wikipost][:content])
    elsif (wikipost = Wikipost.new_post(params[:wikipost].permit(:content, :comment, :position_id, :user_id, :minor, :prev_post_id)))
      position = Position.find(params[:wikipost][:position_id])
      position.update_attribute(:latest_post_id, wikipost.id)
      redirect_to '/positions/' + params[:wikipost][:position_id]
    else
      flash[:alert] = "保存に失敗しました。入力内容を確認して下さい。"
      redirect_to '/positions/' + params[:wikipost][:position_id] + '/edit?content=' + ERB::Util.url_encode(params[:wikipost][:content])
    end
  end
end
