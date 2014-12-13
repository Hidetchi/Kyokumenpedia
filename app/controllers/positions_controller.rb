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
      Headline.update(params[:mode], @positions[0].id)
    elsif (params[:mode] == "req")
      sort_hash = Watch.includes(:position).where("latest_post_id IS NULL").group(:position_id).order('count_position_id desc').limit(100).count(:position_id)
      @positions = sort_hash.map{|key, val| Position.includes(:wikiposts).find_by(id: key)}
      @list_title = "解説リクエスト局面"
      @caption = "あなたの解説を待っている局面があります。是非最初の解説の投稿にご協力下さい。"
      @type = "WATCHERS"
      Headline.update(params[:mode], @positions[0].id)
    elsif (params[:mode] == "hot")
      @positions = Position.where('views > 0').includes(:strategy).order('views desc').limit(20)
      @list_title = "注目の局面"
      @caption = "現在注目を集めている局面を表示しています。"
      @type = "VIEWS"
      Headline.update(params[:mode], @positions[0].id)
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
  end
  
  def export
    @position = Position.find(params[:id])
    render :layout => 'export'
  end
  
  def start
    params[:sfen] = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b -"
    show
    render 'show'
  end

  def statistics
    # Action for Ajax
    @position = Position.find(params[:id])
    @category = params[:category].to_i
    session[:viewing_category] = @category
    @appearances = @position.appearances.includes(:game => :game_source).where('game_sources.category = ?', @category).includes(:next_move).order('games.date desc').limit(50)
    @moves = @position.next_moves.order("stat#{@category}_total desc").where("stat#{@category}_total > 0").includes(:next_position)
  end
end
