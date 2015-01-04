require 'board'
class PositionsController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit]
  
  def list
    if (params[:mode] == "new")
      wikiposts = Wikipost.includes(:position).where("prev_post_id IS NULL").order('updated_at desc').limit(100)
      @positions = wikiposts.map(&:position)
      @list_title = "新しい局面"
      @caption = "初めての解説が投稿された時間が最も新しい局面を表示しています。"
      @type = "FIRST_POST"
    elsif (params[:mode] == "req")
      sort_hash = Watch.includes(:position).where("latest_post_id IS NULL").group(:position_id).order('count_position_id desc').limit(100).count(:position_id)
      @positions = sort_hash.map{|key, val| Position.includes(:wikiposts).find_by(id: key)}
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
    @positions = Position.joins(:latest_post).where('content LIKE ?', "%#{escaped_keyword}%").limit(100)
    @positions = @positions.sort_by{|p| p.views}.reverse
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
          render '404'
          return
        end
        board = @position.to_board
        csa_moves.each do |csa_move|
          rt = board.handle_one_move(csa_move)
          unless (rt == :normal)
            render '404'
            return
          end
        end
        @position = Position.find_or_create(board.to_sfen)
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
      @position = Position.find_or_create(board.to_sfen)
    end
    unless (@position)
      render '404'
      return
    end
    Position.increment_counter(:views, @position.id)
    @category = session[:viewing_category] || 2
    render 'show'
  end

  def edit
    unless (@position = Position.find(params[:id]))
      render '404'
      return
    end
    unless (params[:preview])
      session[:wikiedit] = @position.latest_post ? @position.latest_post.content : ""
      session[:wikicomment] = nil
      session[:latest_post_id] = @position.latest_post_id
    end
  end
  
  def search
    @root_strategies = Strategy.where(ancestry: nil)
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
    @moves = @position.next_moves.order("stat#{@category}_total desc").where("stat#{@category}_total > 0").includes(:next_position)
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
    privilege
    render 'privilege'
  end
end
