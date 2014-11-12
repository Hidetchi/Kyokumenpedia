class GamesController < ApplicationController
  require 'board'

  def create
    @error = nil
    # Check game source password. (If invalid, render error.)
    # Any trusted kifu provider can post kifu (for example 81Dojo) with its unique password.
    unless (game_source = GameSource.find_by(pass: params[:game_source_pass]))
      @error = 'No proper game source specified.'
      return
    end
    # Check handicap code. (If invalid, render error.) 1: even 2: lance-handicap 3: 4: 5: ...... 9: 8-piece-handicap
    unless (Handicap.find_by(id: params[:handicap_id]))
      @error = 'No proper handicap specified.'
      return
    end

    # parse moves from the continuous CSA move string
    csa_moves = []
    rs = params[:csa].gsub %r{[\+\-]\d{4}\w{2}} do |s|
      csa_moves << s
      ""
    end
    if !rs.empty?
      if (rs == '%TORYO')
        csa_moves << rs
      else
        @error = 'Invalid moves.'
        return
      end
    end
    if csa_moves.empty?
      @error = 'No moves specified.'
      return
    end
    board = Board.new
    board.initial(params[:handicap_id].to_i)

    rt = nil
	@sfens = [] # sfen for each move

    @sfens << board.to_sfen
    csa_moves.each do |csa_move|
      if (rt == :sennichite)  # if there is a move when sennichite is already output
        @error = 'Illegal move'
        return
      end
      rt = board.handle_one_move(csa_move)
      unless (rt == :normal || rt == :toryo || rt == :sennichite)  # any other output than these indicate illegal move etc.
        @error = 'Illegal move'
        return
      end
      @sfens << board.to_sfen
    end
    if (rt == :normal)  # if there is no result output even after the last move, it's invalid
      @error = 'No result'
      return
    elsif (rt == :sennnichite)
      result_code = 2
    else
      result_code = board.teban ? 1 : 0
    end
    if (params[:result].to_i != result_code) # when the result does not match
      @error = 'Result does not match'
      return
    end
    # If the kifu is OK, then save the game to record
    unless (game = Game.api_add(params.permit(:black_name, :white_name, :date, :csa, :result, :handicap_id, :native_kid), game_source.id))
      @error = 'Duplicate Kifu'
      return
    end
    # Update relations between positions, moves, etc in background
    Game.delay.update_relations(game.id)
  end
end
