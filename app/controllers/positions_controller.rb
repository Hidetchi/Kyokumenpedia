require 'board'
class PositionsController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit]
  
  def index
    @positions = Position.all.limit(200)
  end

  def show
    board = Board.new
    if (params[:sfen])
      board.set_from_sfen(params[:sfen])
      @position = Position.find_by(sfen: board.to_sfen)
    elsif (params[:sfen1])
      sfens = [params[:sfen1], params[:sfen2], params[:sfen3], params[:sfen4], params[:sfen5], params[:sfen6], params[:sfen7], params[:sfen8], params[:sfen9]]
      board.set_from_sfen(sfens.join("/"))
      @position = Position.find_by(sfen: board.to_sfen)
    else
      @position = Position.find_by(id: params[:id])
    end
    unless (@position)
      render '404'
      return
    end
    session[:wikiedit] = @position.latest_post ? @position.latest_post.content : ""
    @appearances = @position.appearances.select(:game_id, :next_move_id).limit(50).includes(:game => :game_source).includes(:next_move)
    @moves = @position.next_moves.order("stat1_total+stat2_total desc").includes(:next_position)
  end
  
  def edit
    unless (@position = Position.find(params[:id]))
      render '404'
      return
    end
    @preload_content = params[:content] ? params[:content] : ""
  end
end
