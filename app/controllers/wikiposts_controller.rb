require 'board'
class WikipostsController < ApplicationController

  def index
    if (params[:position_id])
      @wikiposts = Wikipost.includes(:position).where(:position_id => params[:position_id]).order('created_at desc').limit(50)
      @list_title = "編集履歴"
      @without_position = true
    elsif (params[:user_id])
      @wikiposts = Wikipost.includes(:position).where(:user_id => params[:user_id]).order('created_at desc').limit(50)
      user = User.find_by(id: params[:user_id])
      @list_title = user.username + "さんのコントリビューション"
      @without_user = true
    else
      @wikiposts = Wikipost.includes(:position).order('created_at desc').limit(50)
      @list_title = "最新の編集"
    end
  end
  
  def show
    @wikipost = Wikipost.find_by(id: params[:id])
  end

  def create
    session[:wikiedit] = params[:wikipost][:content]
    session[:wikicomment] = params[:wikipost][:comment]
    session[:latest_post_id] = params[:wikipost][:latest_post_id]
    if (params[:preview])
      redirect_to edit_position_path(id: params[:position_id], preview: true)
    else
      session[:latest_post_id] = Position.find(params[:position_id]).latest_post_id
      params[:wikipost][:prev_post_id] = session[:latest_post_id]
      params[:wikipost][:minor] = 0 unless (params[:wikipost][:prev_post_id])
      params[:wikipost][:position_id] = params[:position_id]
      params[:wikipost][:user_id] = current_user.id
      if (session[:latest_post_id] != nil && session[:latest_post_id] != params[:wikipost][:latest_post_id].to_i)
        flash[:alert] = "他ユーザが編集を行ったため、編集内容の競合が発生しました。編集規模が小さい場合は、最新の記事を確認後、改めて編集を実施して下さい。そのまま投稿を続ける場合は、後から他ユーザの編集を確認し調整を実施して下さい。"
        redirect_to edit_position_path(id: params[:position_id], preview: true)
      elsif (wikipost = Wikipost.new_post(params[:wikipost].permit(:content, :comment, :position_id, :user_id, :minor, :prev_post_id)))
        wikipost.position.update_attribute(:latest_post_id, wikipost.id)
        unless (params[:wikipost][:minor].to_i == 1)
          wikipost.position.watchers.each do |watcher|
            Feeder.delay.wikipost_to_watcher(watcher.id, wikipost.id) if watcher.receive_watching
          end
          watcher_ids = wikipost.position.watchers.pluck(:id)
          wikipost.user.followers.each do |follower|
            unless watcher_ids.include?(follower.id)
              Feeder.delay.wikipost_to_follower(follower.id, wikipost.id) if follower.receive_following
            end
          end
        end
        wikipost.reward_user
        expire_fragment('db_stat')
        redirect_to position_path(params[:position_id])
      else
        flash[:alert] = "保存に失敗しました。入力内容を確認して下さい。"
        redirect_to edit_position_path(id: params[:position_id], preview: true)
      end
    end
  end
  
  def likers
    @wikipost = Wikipost.includes(:likers).find_by(id: params[:id])
  end

end
