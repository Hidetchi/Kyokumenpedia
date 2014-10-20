class PositionsController < ApplicationController
  def index
    @positions = Position.all
  end

  def show
    @position = Position.find(params[:id])
    @appearances = @position.appearances
    @moves = @position.next_moves
    @prev_moves_sorted = @position.prev_moves.order('stat1_total + stat2_total desc')
    @counts_sorted = @appearances.group(:num).order('count_num desc').count('num').keys
  end
end
