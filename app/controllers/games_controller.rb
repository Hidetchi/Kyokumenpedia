class GamesController < ApplicationController
  require 'board'
  protect_from_forgery :except => 'create'

  def create
    @error_message = nil
    @error_message = catch :error_msg do
      # Check game source password. Give error if invalid. Any trusted kifu provider can post kifu (for example 81Dojo) with its unique password.
      unless (@game_source = GameSource.find_by(pass: params[:game_source_pass]))
        throw :error_msg, 'Authentication failed. Access info has been logged.'
      end
      # Check handicap code. Give error if invalid. 1: even 2: lance-handicap 3: 4: 5: ...... 9: 8-piece-handicap
      unless (@handicap = Handicap.find_by(id: params[:handicap_id]))
        throw :error_msg, 'No proper handicap specified.'
      end

      # parse moves from the continuous CSA move string
      csa_moves = []
      rs = params[:csa].gsub %r{[\+\-]\d{4}\w{2}} do |s|
        csa_moves << s
        ""
      end
      if !rs.empty?
        throw :error_msg, 'Invalid moves.' unless (rs == '%TORYO')
        csa_moves << rs
      end
      throw :error_msg, 'No moves specified' if csa_moves.empty?
      
      board = Board.new
      board.initial(params[:handicap_id].to_i)

      @sfens = [] # sfen for each move
      @sfens << board.to_sfen
      rt = nil
      csa_moves.each do |csa_move|
        # if there is a move when sennichite has been already output
        throw :error_msg, 'Additional move after sennichite.' if (rt == :sennichite)
        rt = board.handle_one_move(csa_move)
        unless (rt == :normal || rt == :toryo || rt == :sennichite)  # any other output than these indicate illegal move etc.
          throw :error_msg, 'Illegal move'
        end
        @sfens << board.to_sfen unless rt == :toryo
      end
      # if there is no result output even after the last move, it's invalid
      throw :error_msg, 'No result' if (rt == :normal)
      if (rt == :sennnichite)
        result_code = 2
      else
        result_code = board.teban ? 1 : 0
      end
      # when the result does not match
      throw :error_msg, 'Result does not match' if (params[:result].to_i != result_code)
      @winner = (result_code == 0 ? "Sente" : (result_code == 1 ? "Gote" : "Draw"))
      # If the kifu is OK, then save the game to record
      unless (game = Game.api_add(params.permit(:black_name, :white_name, :date, :csa, :result, :handicap_id, :native_kid), @game_source.id))
        throw :error_msg, 'Duplicate Kifu'
      end
      # Update relations between positions, moves, etc in background
      Game.delay.update_relations(game.id)
      throw :error_msg, nil
    end
    @response = Hash.new
    if (@error_message)
      @response["result"] = "Error: " + @error_message
    else
      @response["result"] = "Success"
      @response["moves"] = @sfens.length
      @response["winner"] = @winner
      @response["positions"] = @sfens
      @response["player_sente"] = params[:black_name]
      @response["player_gote"] = params[:white_name]
      @response["date"] = params[:date]
      @response["handicap"] = @handicap.name
      @response["identification"] = @game_source.name
    end
    render :xml => @response.to_xml(:root => 'api_response')
  end
end
