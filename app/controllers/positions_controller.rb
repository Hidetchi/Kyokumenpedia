class PositionsController < ApplicationController
  def index
    @positions = Position.all.limit(200)
  end

  def show
    if (params[:sfen])
      @position = Position.find_by(sfen: params[:sfen])
    elsif (params[:sfen1])
      sfens = [params[:sfen1], params[:sfen2], params[:sfen3], params[:sfen4], params[:sfen5], params[:sfen6], params[:sfen7], params[:sfen8], params[:sfen9]]
      @position = Position.find_by(sfen: sfens.join("/"))
    else
      @position = Position.find_by(id: params[:id])
    end
    unless (@position)
      render '404'
      return
    end
    board = ApplicationHelper::Board.new
    board.set_from_str(@position.csa)
    @board_table = board.to_html_table
    @appearances = @position.appearances.limit(50)
    @moves = @position.next_moves.order("stat1_total+stat2_total desc")
    @prev_moves_sorted = @position.prev_moves.order('stat1_total + stat2_total desc')
    @counts_sorted = @appearances.group(:num).order('count_num desc').count('num').keys
  end
end
