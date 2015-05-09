require 'board'
class PositionsController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit]
  
  def list
    if (params[:mode] == "new")
#      wikiposts = Wikipost.includes(:position).where("prev_post_id IS NULL").order('updated_at desc').limit(100)
      wikiposts = Wikipost.preload(:position).group(:position_id).order('id desc').limit(100)
      @positions = wikiposts.map(&:position)
      @values = wikiposts.map{|w| w}
      @list_title = "新しい局面"
      @caption = "初めての解説が投稿された時間が最も新しい局面を表示しています。"
      @type = "FIRST_POST"
    elsif (params[:mode] == "req")
      sort_hash = Watch.joins(:position).includes(:position).where("latest_post_id IS NULL").group(:position_id).order('count_position_id desc').limit(100).count(:position_id)
      keys = sort_hash.map{|key, val| key}
      @positions = Position.where(id: keys).order("field(id,#{keys.join(',')})")
      @values = sort_hash.map{|key, val| val}
      @list_title = "解説リクエスト局面"
      @caption = "あなたの解説を待っている局面があります。是非最初の解説の投稿にご協力下さい。"
      @type = "WATCHERS"
      Headline.update(params[:mode], @positions[0])
    elsif (params[:mode] == "hot")
      @positions = Position.where('views > 0').includes(:strategy).order('views desc').limit(20)
      @list_title = "いま人気の局面"
      @caption = "現在注目を集めている人気の局面を表示しています。"
      @type = "VIEWS"
      Headline.update(params[:mode], @positions[0])
    elsif (params[:mode] == "pic")
      @pickups = EditorPickup.order('created_at desc').limit(10)
      render 'pickups'
    elsif (params[:mode] == "mem")
      if (session[:history])
        sanitized_query = ActiveRecord::Base.send(:sanitize_sql_array, ["field(id ,?)",session[:history]])
        @positions = Position.where(id: session[:history]).order(sanitized_query).includes(:strategy)
      else
        @positions = []
      end
      @list_title = "閲覧履歴"
      @caption = "最近見た局面のキャッシュ履歴を表示しています。(ログアウトするとクリアされます)"
      @type = "HISTORY"
    else
      @list_title = "局面リスト"
      @positions = []
    end
  end
  
  def keyword
    @keyword = params[:keyword]
    escaped_keyword = @keyword.gsub(/[\\%_]/){|m| "\\#{m}"}
    if (@keyword.length <= 1)
      flash[:alert] = "キーワードが短すぎます"
      redirect_to :back
    end
    @wikiposts = Wikipost.includes(:position).where(id: Wikipost.group(:position_id).pluck('max(id)')).where('content like ?', "%#{escaped_keyword}%").order('positions.views desc').limit(100)
  end

  def show
    if (params[:id])
      @position = Position.find_by(id: params[:id])
      if (params[:moves])
        csa_moves = []
        rs = params[:moves].gsub %r{[\+\-]\d{4}\w{2}} do |s|
          csa_moves << s
          ""
        end
        if (!rs.empty? || csa_moves.empty?)
          params[:preview] ? (render :nothing => true) : (render '404')
          return
        end
        board = @position.to_board
        csa_moves.each do |csa_move|
          rt = board.handle_one_move(csa_move)
          unless (rt == :normal)
            params[:preview] ? (render :nothing => true) : (render '404')
            return
          end
        end
        sfen = board.to_sfen
      end
    else
      board = Board.new
      if (params[:bod] && params[:bod] =~ /の持駒：/)
        board.set_from_bod(params[:bod])
      elsif (params[:sfen])
        board.set_from_sfen(params[:sfen])
      elsif (params[:sfen1])
        sfens = [params[:sfen1], params[:sfen2], params[:sfen3], params[:sfen4], params[:sfen5], params[:sfen6], params[:sfen7], params[:sfen8], params[:sfen9]]
        board.set_from_sfen(sfens.join("/"))
      end
      sfen = board.to_sfen
    end
    if (params[:preview])
      sfen = sfen || @position.sfen
      @board = Board.new
      @board.set_from_sfen(sfen)
      render 'preview', :layout => 'preview'
      return
    end
    @position = Position.find_or_create(sfen) if sfen
    unless (@position)
      render '404'
      return
    end
    Position.increment_counter(:views, @position.id)
    @referrers = @position.referrers.order('views desc')
    @category = session[:viewing_category] || 2
    @notes = @position.notes.includes(:user)
    @notes = @notes.where(public: true) unless user_signed_in? && current_user.is_admin?
    @referrer_notes = @position.referrer_notes.includes(:user, :position) # NoteReference exists only for public=true notes
    if user_signed_in?
      @mynote = Note.find_by(:user_id => current_user.id, :position_id => @position.id)

      session[:history] = [] unless session[:history]
      session[:history] = [@position.id] | session[:history]
      session[:history].pop if session[:history].length > 50
    end
    render 'show'
  end

  def edit
    unless (@position = Position.find(params[:id]))
      render '404'
      return
    end
    if (current_user.card >= 4)
      flash[:alert] = "編集制限カードが出ているため投稿できません"
      raise UserException::AccessDenied
    end
    if (params[:wikipost])
      @wikiedit = params[:wikipost][:content]
      @wikicomment = params[:wikipost][:comment]
      @latest_post_id = params[:wikipost][:latest_post_id]
      puts "OK"
    #unless (params[:preview])
    else
      @wikiedit = @position.latest_post ? @position.latest_post.content : ""
      @wikicomment = nil
      @latest_post_id = @position.latest_post_id
    end
  end
  
  def post 
    @position = Position.find(params[:id])
    @wikiedit = params[:wikipost][:content]
    @wikicomment = params[:wikipost][:comment]
    @latest_post_id = params[:wikipost][:latest_post_id].to_i
    flash[:alert] = nil
    if (params[:preview])
      render 'edit' and return
    elsif (current_user.card >= 4)
      flash[:alert] = "編集制限カードが出ているため投稿できません"
      render 'edit' and return
    else
      @latest_post_id = @position.latest_post_id
      params[:wikipost][:prev_post_id] = @latest_post_id
      params[:wikipost][:minor] = 0 unless (params[:wikipost][:prev_post_id])
      params[:wikipost][:position_id] = params[:id]
      params[:wikipost][:user_id] = current_user.id
      if (@latest_post_id != nil && @latest_post_id != params[:wikipost][:latest_post_id].to_i)
        flash[:alert] = "他ユーザが編集を行ったため、編集内容の競合が発生しました。編集規模が小さい場合は、最新の記事を確認後、改めて編集を実施して下さい。そのまま投稿を続ける場合は、後から他ユーザの編集を確認し調整を実施して下さい。"
        render 'edit' and return
      elsif (params[:wikipost][:content] =~ /#BLAME/ && !current_user.can_access_privilege?)
        flash[:alert] = "#BLAMEタグはモデレータ以外は投稿できません。改訂後は#BLAMEタグを消去して下さい。"
        render 'edit' and return
      elsif (wikipost = Wikipost.new_post(params[:wikipost].permit(:content, :comment, :position_id, :user_id, :minor, :prev_post_id)))
        wikipost.position.update_attribute(:latest_post_id, wikipost.id)
        wikipost.user.update_attributes(card: 1) if wikipost.user.card == 0
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
        bot_tweet(wikipost.to_create_tweet) if wikipost.prev_post_id == nil
        wikipost.update_references
        expire_fragment('db_stat')
        redirect_to position_path(params[:id])
      else
        flash[:alert] = "保存に失敗しました。入力内容を確認して下さい。"
        render 'edit' and return
      end
    end
  end
  
  def search
    @root_strategies = proc {Strategy.where(ancestry: nil)}
  end
  
  def export
    @position = Position.find(params[:id])
    render :layout => 'export'
  end
  
  def start
    board = Board.new
    board.initial(params[:handicap_id].to_i)
    params[:sfen] = board.to_sfen
    show
  end

  def statistics
    # Action for Ajax
    @position = Position.find(params[:id])
    @category = params[:category].to_i
    session[:viewing_category] = @category
    game_source_ids = [@category]  #Change this conversion accordingly when you've added new GameSource
    @appearances = @position.appearances.preload(:next_move).eager_load(:game).where('games.game_source_id' => game_source_ids).order('appearances.id desc').limit(50)
    if current_user && current_user.can_view_pro?
      @moves = @position.next_moves.order("stat#{@category}_total desc").includes(:next_position)
    else
      @moves = @position.next_moves.order("stat#{@category}_total desc").where("stat#{@category}_total > 0 OR (stat1_total = 0 AND stat2_total = 0 AND stat3_total = 0)").includes(:next_position)
    end
  end

  def privilege
    raise UserException::AccessDenied unless (current_user && current_user.can_access_privilege?)
    @position = Position.find(params[:id])
    @root_strategies = Strategy.where(ancestry: nil)
  end

  def pickup
    raise UserException::AccessDenied unless (current_user && current_user.can_access_privilege?)
    pickup = EditorPickup.create(:user_id => current_user.id, :position_id => params[:id], :comment => params[:pickup][:comment]) if params[:pickup][:comment] != ""
    if (pickup)
      position = Position.find(params[:id])
      Headline.update("pic", position)
    end
    params[:mode] = "pic"
    list
  end

  def set_main
    raise UserException::AccessDenied unless (current_user && current_user.can_access_privilege?)
    @position = Position.find(params[:id])
    @position.strategy.update_attributes(:main_position_id => @position.id)
    expire_fragment('strategy_tree')
    privilege
    render 'privilege'
  end
end
