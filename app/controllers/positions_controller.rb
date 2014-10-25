class PositionsController < ApplicationController
  def index
    @positions = Position.all.limit(200)
  end

  def show
    @position = Position.find(params[:id])
    board = ApplicationHelper::Board.new
    board.set_from_str(@position.csa)
    @board_table = board.to_html_table
    @appearances = @position.appearances.limit(50)
    @moves = @position.next_moves.order("stat1_total+stat2_total desc")
    @prev_moves_sorted = @position.prev_moves.order('stat1_total + stat2_total desc')
    @counts_sorted = @appearances.group(:num).order('count_num desc').count('num').keys
  end
end
