require 'board'
class WikipostsController < ApplicationController

  def index
    if (params[:position_id])
      @wikiposts = Wikipost.where(:position_id => params[:position_id]).order('created_at desc').limit(50)
      @list_title = "編集履歴"
    elsif (params[:user_id])
      @wikiposts = Wikipost.where(:user_id => params[:user_id]).order('created_at desc').limit(50)
      user = User.find_by(id: params[:user_id])
      @list_title = user.username + "さんのコントリビューション"
    else
      @wikiposts = Wikipost.all.order('created_at desc').limit(50)
      @list_title = "最新の変更"
    end
  end
  
  def show
    @wikipost = Wikipost.find_by(id: params[:id])
  end

  def create
    session[:wikiedit] = params[:wikipost][:content]
    session[:wikicomment] = params[:wikipost][:comment]
    if (params[:wikipost][:content] =~ /<(img\s|font\s|hr>|h\d>|ul>|ol>|li>|a\s|table|span\s|b>|u>|i>|strong>)/)
      flash[:alert] = "禁止タグが含まれています。(許可されているタグは<br><ref>のみです)"
      redirect_to :controller => 'positions', :action => 'edit', :id => params[:wikipost][:position_id]
    elsif (params[:preview])
      redirect_to :controller => 'positions', :action => 'edit', :id => params[:wikipost][:position_id]
    elsif (wikipost = Wikipost.new_post(params[:wikipost].permit(:content, :comment, :position_id, :user_id, :minor, :prev_post_id)))
      position = Position.find(params[:wikipost][:position_id])
      position.update_attribute(:latest_post_id, wikipost.id)
      redirect_to '/positions/' + params[:wikipost][:position_id]
    else
      flash[:alert] = "保存に失敗しました。入力内容を確認して下さい。"
      redirect_to :controller => 'positions', :action => 'edit', :id => params[:wikipost][:position_id]
    end
  end
end
