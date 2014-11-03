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
    @board = Board.new
    @board.initial(params[:handicap_id].to_i)

    sfens = [] # sfen for each move, which is used to identify/register Position model.
    @positions = [] # Position models
    rt = nil

    sfens << @board.to_sfen
    csa_moves.each do |csa_move|
      rt = @board.handle_one_move(csa_move)
      unless (rt == :normal || rt == :toryo)
        @error = 'Illegal move'
        return
      end
      sfens << @board.to_sfen
    end

    # If the kifu is OK, then update database
    strategy = nil
    unless (@game = Game.api_add(params.permit(:black_name, :white_name, :date, :csa, :result, :handicap_id, :native_kid), game_source.id))
      @error = 'Duplicate Kifu'
      return
    end
    for i in 0..(sfens.length - 1) do
      @positions << Position.find_or_create(sfens[i])
    end
    position_already = Hash::new(false)
    move_already = Hash::new(false)
    begin
      for i in 0..(@positions.length - 1) do
        unless (i >= @positions.length - 1)
          move = Move.find_or_new(@positions[i].id, @positions[i+1].id, csa_moves[i])
          unless move_already[sfens[i]+sfens[i+1]]
            move.update_stat(game_source.category)
          end
          move_already[sfens[i]+sfens[i+1]] = true
        end

        unless position_already[sfens[i]]
          strategy = @positions[i].update_strategy(strategy)
          @positions[i].games << @game
          @positions[i].update_stat(game_source.category, @game.result)

          appearance = Appearance.last
          appearance.num = i
          appearance.next_move = move
          appearance.save
        end
        position_already[sfens[i]] = true
      end
    rescue
      @game.destroy
      @error = 'Database error.'
      return
    end

  end

end
