module ApplicationHelper

class Board
  def initialize(move_count=0)
    @sente_hands = Array::new
    @gote_hands  = Array::new
    @history       = Hash::new(0)
    @sente_history = Hash::new(0)
    @gote_history  = Hash::new(0)
    @array = [[], [], [], [], [], [], [], [], [], []]
    @move_count = move_count
    @teban = nil # black => true, white => false
    @initial_moves = []
    @handicap = 1
  end
  attr_accessor :array, :sente_hands, :gote_hands, :history, :sente_history, :gote_history, :teban
  attr_reader :move_count
  
  # Initial moves for a Buoy game. If it is an empty array, the game is
  # normal with the initial setting; otherwise, the game is started after the
  # moves.
  attr_reader :initial_moves

  def deep_copy
    return Marshal.load(Marshal.dump(self))
  end

  def initial(handicap)
    PieceKY::new(self, 1, 1, false) if (handicap < 7)
    PieceKE::new(self, 2, 1, false) if (handicap < 8)
    PieceGI::new(self, 3, 1, false) if (handicap < 9)
    PieceKI::new(self, 4, 1, false)
    @gote_ou = PieceOU::new(self, 5, 1, false)
    PieceKI::new(self, 6, 1, false)
    PieceGI::new(self, 7, 1, false) if (handicap < 9)
    PieceKE::new(self, 8, 1, false) if (handicap < 8)
    PieceKY::new(self, 9, 1, false) if (handicap < 7 && handicap != 2 && handicap != 4)
    PieceKA::new(self, 2, 2, false) if (handicap < 6 && handicap != 3)
    PieceHI::new(self, 8, 2, false) if (handicap < 4)
    (1..9).each do |i|
      PieceFU::new(self, i, 3, false)
    end

    PieceKY::new(self, 1, 9, true)
    PieceKE::new(self, 2, 9, true)
    PieceGI::new(self, 3, 9, true)
    PieceKI::new(self, 4, 9, true)
    @sente_ou = PieceOU::new(self, 5, 9, true)
    PieceKI::new(self, 6, 9, true)
    PieceGI::new(self, 7, 9, true)
    PieceKE::new(self, 8, 9, true)
    PieceKY::new(self, 9, 9, true)
    PieceKA::new(self, 8, 8, true)
    PieceHI::new(self, 2, 8, true)
    (1..9).each do |i|
      PieceFU::new(self, i, 7, true)
    end
    @teban = handicap == 1
    @gote_base_point = [0, 0, 1, 5, 5, 6, 10, 12, 14, 16][handicap]
    @handicap = handicap
  end

  def empty
    initialize
  end

  # Set up a board with the strs.
  # Failing to parse the moves raises an StandardError.
  # @param strs a board text
  #
  def set_from_str(strs) #TODO define @sente_ou and @gote_ou
    strs.each_line do |str|
      case str
      when /^P\d/
        str.sub!(/^P(.)/, '')
        y = $1.to_i
        x = 9
        while (str.length > 2)
          str.sub!(/^(...?)/, '')
          one = $1
          if (one =~ /^([\+\-])(..)/)
            sg = $1
            name = $2
            if (sg == "+")
              sente = true
            else
              sente = false
            end
            if ((x < 1) || (9 < x) || (y < 1) || (9 < y))
              raise "bad position #{x} #{y}"
            end
            case (name)
            when "FU"
              PieceFU::new(self, x, y, sente)
            when "KY"
              PieceKY::new(self, x, y, sente)
            when "KE"
              PieceKE::new(self, x, y, sente)
            when "GI"
              PieceGI::new(self, x, y, sente)
            when "KI"
              PieceKI::new(self, x, y, sente)
            when "OU"
              PieceOU::new(self, x, y, sente)
            when "KA"
              PieceKA::new(self, x, y, sente)
            when "HI"
              PieceHI::new(self, x, y, sente)
            when "TO"
              PieceFU::new(self, x, y, sente, true)
            when "NY"
              PieceKY::new(self, x, y, sente, true)
            when "NK"
              PieceKE::new(self, x, y, sente, true)
            when "NG"
              PieceGI::new(self, x, y, sente, true)
            when "UM"
              PieceKA::new(self, x, y, sente, true)
            when "RY"
              PieceHI::new(self, x, y, sente, true)
            else
              raise "unkown piece #{name}"
            end
          end
          x = x - 1
        end
      when /^P([\+\-])/
        sg = $1
        if (sg == "+")
          sente = true
        else
          sente = false
        end
        str.sub!(/^../, '')
        while (str.length > 3)
          str.sub!(/^..(..)/, '')
          name = $1
          case (name)
          when "FU"
            PieceFU::new(self, 0, 0, sente)
          when "KY"
            PieceKY::new(self, 0, 0, sente)
          when "KE"
            PieceKE::new(self, 0, 0, sente)
          when "GI"
            PieceGI::new(self, 0, 0, sente)
          when "KI"
            PieceKI::new(self, 0, 0, sente)
          when "KA"
            PieceKA::new(self, 0, 0, sente)
          when "HI"
            PieceHI::new(self, 0, 0, sente)
          else
            raise "unkown piece #{name}"
          end
        end # while
      when /^\+$/
        @teban = true
      when /^\-$/
        @teban = false
      else
        raise "bad line: #{str}"
      end # case
    end # do
  end

  def have_piece?(hands, name)
    piece = hands.find { |i|
      i.name == name
    }
    return piece
  end

  def move_to(x0, y0, x1, y1, name, sente)
    if (sente)
      hands = @sente_hands
    else
      hands = @gote_hands
    end

    if ((x0 == 0) || (y0 == 0))
      piece = have_piece?(hands, name)
      return :illegal if (piece == nil || ! piece.move_to?(x1, y1, name))
      piece.move_to(x1, y1)
    else
      if (@array[x0][y0] == nil || !@array[x0][y0].move_to?(x1, y1, name))
        return :illegal
      end
      @array[x0][y0].promoted = (@array[x0][y0].name != name) # promoted ?
      if (@array[x1][y1]) # capture
        if (@array[x1][y1].name == "OU")
          return :outori        # return board update
        end
        @array[x1][y1].sente = @array[x0][y0].sente
        @array[x1][y1].move_to(0, 0)
        hands.sort! {|a, b| # TODO refactor. Move to Piece class
          a.name <=> b.name
        }
      end
      @array[x0][y0].move_to(x1, y1)
    end
    @move_count += 1
    @teban = @teban ? false : true
    return true
  end

  def look_for_ou(sente)
    if (sente) then
      return @sente_ou
    else
      return @gote_ou
    end
  end

  # not checkmate, but check. sente is checked.
  def checkmated?(sente)        # sente is loosing
    ou = look_for_ou(sente)
    return false unless (ou)
    x = 1
    while (x <= 9)
      y = 1
      while (y <= 9)
        if (@array[x][y] &&
            (@array[x][y].sente != sente))
          if (@array[x][y].movable_grids.include?([ou.x, ou.y]))
            return true
          end
        end
        y = y + 1
      end
      x = x + 1
    end
    return false
  end

  def uchifuzume?(sente)
    rival_ou = look_for_ou(! sente)   # rival's ou
    if (sente)                  # rival is gote
      if ((rival_ou.y != 9) &&
          (@array[rival_ou.x][rival_ou.y + 1]) &&
          (@array[rival_ou.x][rival_ou.y + 1].name == "FU") &&
          (@array[rival_ou.x][rival_ou.y + 1].sente == sente)) # uchifu true
        fu_x = rival_ou.x
        fu_y = rival_ou.y + 1
      else
        return false
      end
    else                        # gote
      if ((rival_ou.y != 1) &&
          (@array[rival_ou.x][rival_ou.y - 1]) &&
          (@array[rival_ou.x][rival_ou.y - 1].name == "FU") &&
          (@array[rival_ou.x][rival_ou.y - 1].sente == sente)) # uchifu true
        fu_x = rival_ou.x
        fu_y = rival_ou.y - 1
      else
        return false
      end
    end

    ## case: rival_ou is moving
    rival_ou.movable_grids.each do |(cand_x, cand_y)|
      tmp_board = deep_copy
      s = tmp_board.move_to(rival_ou.x, rival_ou.y, cand_x, cand_y, "OU", ! sente)
      raise "internal error" if (s != true)
      if (! tmp_board.checkmated?(! sente)) # good move
        return false
      end
    end

    ## case: rival is capturing fu
    x = 1
    while (x <= 9)
      y = 1
      while (y <= 9)
        if (@array[x][y] &&
            (@array[x][y].sente != sente) &&
            @array[x][y].movable_grids.include?([fu_x, fu_y])) # capturable
          
          names = []
          if (@array[x][y].promoted)
            names << @array[x][y].promoted_name
          else
            names << @array[x][y].name
            if @array[x][y].promoted_name && 
               @array[x][y].move_to?(fu_x, fu_y, @array[x][y].promoted_name)
              names << @array[x][y].promoted_name 
            end
          end
          names.map! do |name|
            tmp_board = deep_copy
            s = tmp_board.move_to(x, y, fu_x, fu_y, name, ! sente)
            if s == :illegal
              s # result
            else
              tmp_board.checkmated?(! sente) # result
            end
          end
          all_illegal = names.find {|a| a != :illegal}
          raise "internal error: legal move not found" if all_illegal == nil
          r = names.find {|a| a == false} # good move
          return false if r == false # found good move
        end
        y = y + 1
      end
      x = x + 1
    end
    return true
  end

  # @[sente|gote]_history has at least one item while the player is checking the other or 
  # the other escapes.
  def update_sennichite(player)
    str = to_s
    @history[str] += 1
    if checkmated?(!player)
      if (player)
        @sente_history["dummy"] = 1  # flag to see Sente player is checking Gote player
      else
        @gote_history["dummy"]  = 1  # flag to see Gote player is checking Sente player
      end
    else
      if (player)
        @sente_history.clear # no more continuous check
      else
        @gote_history.clear  # no more continuous check
      end
    end
    if @sente_history.size > 0  # possible for Sente's or Gote's turn
      @sente_history[str] += 1
    end
    if @gote_history.size > 0   # possible for Sente's or Gote's turn
      @gote_history[str] += 1
    end
  end

  def oute_sennichite?(player)
    return nil unless sennichite?

    if player
      # sente's turn
      if (@sente_history[to_s] >= 4)   # sente is checking gote
        return :oute_sennichite_sente_lose
      elsif (@gote_history[to_s] >= 3) # sente is escaping
        return :oute_sennichite_gote_lose
      else
        return nil # Not oute_sennichite, but sennichite
      end
    else
      # gote's turn
      if (@gote_history[to_s] >= 4)     # gote is checking sente
        return :oute_sennichite_gote_lose
      elsif (@sente_history[to_s] >= 3) # gote is escaping
        return :oute_sennichite_sente_lose
      else
        return nil # Not oute_sennichite, but sennichite
      end
    end
  end

  def sennichite?
    if (@history[to_s] >= 4) # already 3 times
      return true
    end
    return false
  end

  def good_kachi?(sente)
    if (checkmated?(sente))
      return false 
    end
    
    ou = look_for_ou(sente)
    if (sente && (ou.y >= 4))
      return false     
    end  
    if (! sente && (ou.y <= 6))
      return false 
    end
      
    number = 0
    point = 0

    if (sente)
      hands = @sente_hands
      r = [1, 2, 3]
    else
      point += @gote_base_point
      hands = @gote_hands
      r = [7, 8, 9]
    end
    r.each do |y|
      x = 1
      while (x <= 9)
        if (@array[x][y] &&
            (@array[x][y].sente == sente) &&
            (@array[x][y].point > 0))
          point = point + @array[x][y].point
          number = number + 1
        end
        x = x + 1
      end
    end
    hands.each do |piece|
      point = point + piece.point
    end

    if (number < 10)
      return false     
    end  
    if (sente)
      if (point < 28)
        return false 
      end  
    else
      if (point < 27)
        return false 
      end
    end

    return true
  end

  # sente is nil only if tests in test_board run
  # @return
  #   - :normal
  #   - :toryo 
  #   - :kachi_win 
  #   - :kachi_lose 
  #   - :sennichite 
  #   - :oute_sennichite_sente_lose 
  #   - :oute_sennichite_gote_lose 
  #   - :illegal 
  #   - :uchifuzume 
  #   - :oute_kaihimore 
  #   - (:outori will not be returned)
  #
  def handle_one_move(str, sente=nil)
    if (str =~ /^([\+\-])(\d)(\d)(\d)(\d)([A-Z]{2})/)
      sg = $1
      x0 = $2.to_i
      y0 = $3.to_i
      x1 = $4.to_i
      y1 = $5.to_i
      name = $6
    elsif (str =~ /^%KACHI/)
      raise ArgumentError, "sente is null", caller if sente == nil
      if (good_kachi?(sente))
        return :kachi_win
      else
        return :kachi_lose
      end
    elsif (str =~ /^%TORYO/)
      return :toryo
    else
      return :illegal
    end
    
    if (((x0 == 0) || (y0 == 0)) && # source is not from hand
        ((x0 != 0) || (y0 != 0)))
      return :illegal
    elsif ((x1 == 0) || (y1 == 0)) # destination is out of board
      return :illegal
    end
    
    if (sg == "+")
      sente = true if sente == nil           # deprecated
      return :illegal unless sente == true   # black player's move must be black
      hands = @sente_hands
    else
      sente = false if sente == nil          # deprecated
      return :illegal unless sente == false  # white player's move must be white
      hands = @gote_hands
    end

    return :illegal if (move_to(x0, y0, x1, y1, name, sente) == :illegal)
    return :oute_kaihimore if (checkmated?(sente))
    update_sennichite(sente)
    os_result = oute_sennichite?(sente)
    return os_result if os_result # :oute_sennichite_sente_lose or :oute_sennichite_gote_lose
    return :sennichite if sennichite?

    if ((x0 == 0) && (y0 == 0) && (name == "FU") && uchifuzume?(sente))
      return :uchifuzume
    end

    return :normal
  end

  def do_moves_str(csa)
    new_board = deep_copy
    ret = []
    rs = csa.gsub %r{[\+\-]\d{4}\w{2}} do |s|
           ret << s
           ""
         end
    ret.each do |move|
      new_board.handle_one_move(move)
    end
    return new_board
  end

  def to_s
    a = Array::new
    y = 1
    while (y <= 9)
      a.push(sprintf("P%d", y))
      x = 9
      while (x >= 1)
        piece = @array[x][y]
        if (piece)
          s = piece.to_s
        else
          s = " * "
        end
        a.push(s)
        x = x - 1
      end
      a.push(sprintf("\n"))
      y = y + 1
    end
    if (! sente_hands.empty?)
      a.push("P+")
      sente_hands.each do |p|
        a.push("00" + p.name)
      end
      a.push("\n")
    end
    if (! gote_hands.empty?)
      a.push("P-")
      gote_hands.each do |p|
        a.push("00" + p.name)
      end
      a.push("\n")
    end
    a.push("%s\n" % [@teban ? "+" : "-"])
    return a.join
  end

  def to_sfen
    sfen = ""
    for y in 1..9 do
      ns = 0
      for x in 9.downto(1) do
        if (@array[x][y])
          sfen += ns.to_s if (ns > 0)
          ns = 0
          sfen += @array[x][y].to_sfen
        else
          ns += 1
        end
      end
      sfen += ns.to_s if (ns > 0)
      sfen += "/" unless (y == 9)
    end
    sfen += " " + (@teban ? "b " : "w ")
    if (gote_hands.empty? && sente_hands.empty?)
      sfen += "-"
    else
      hand_pieces = Hash.new
      hand_pieces = {"R" => 0, "B" => 0, "G" => 0, "S" => 0, "N" => 0, "L" => 0, "P" => 0,
                     "r" => 0, "b" => 0, "g" => 0, "s" => 0, "n" => 0, "l" => 0, "p" => 0}
      (gote_hands + sente_hands).each do |p|
        hand_pieces[p.to_sfen] += 1
      end
      hand_pieces.each{|key, value|
        next if (value == 0)
        value = value.to_s
        value = "" if (value == "1")
        sfen += value + key
      }
    end
    return sfen
  end

  def to_html_table
    tag = "<table class='board_wrapper'><tr><td class='komadai_gote'>△"
    if (gote_hands.empty?)
      tag += "<br>な<br>し"
    else
      hand_pieces = Hash.new
      hand_pieces = {"飛" => 0, "角" => 0, "金" => 0, "銀" => 0, "桂" => 0, "香" => 0, "歩" => 0}
      gote_hands.each do |p|
        hand_pieces[p.to_diag] += 1
      end
      hand_pieces.each {|key, value|
        next if (value == 0)
        tag += "<br>" + key + (value > 1 ? value.to_s : "")
      }
    end
    tag += "<td class='board_frame'><table class='board'>"
    for y in 1..9 do
      tag += "<tr>"
      for x in 9.downto(1) do
        if (@array[x][y])
          tag += @array[x][y].sente ? "<td>" : "<td class='gote'>"
          tag += @array[x][y].to_diag
        else
          tag += "<td>"
        end
      end
    end
    tag += "</table><td class='komadai_sente'>▲"
    if (sente_hands.empty?)
      tag += "<br>な<br>し"
    else
      hand_pieces = Hash.new
      hand_pieces = {"飛" => 0, "角" => 0, "金" => 0, "銀" => 0, "桂" => 0, "香" => 0, "歩" => 0}
      sente_hands.each do |p|
        hand_pieces[p.to_diag] += 1
      end
      hand_pieces.each {|key, value|
        next if (value == 0)
        tag += "<br>" + key + (value > 1 ? value.to_s : "")
      }
    end
    tag += "</table>"
    return tag
  end

end

class Piece
  PROMOTE = {"FU" => "TO", "KY" => "NY", "KE" => "NK", 
             "GI" => "NG", "KA" => "UM", "HI" => "RY"}
  def initialize(board, x, y, sente, promoted=false)
    @board = board
    @x = x
    @y = y
    @sente = sente
    @promoted = promoted

    if ((x == 0) || (y == 0))
      if (sente)
        hands = board.sente_hands
      else
        hands = board.gote_hands
      end
      hands.push(self)
      hands.sort! {|a, b|
        a.name <=> b.name
      }
    else
      @board.array[x][y] = self
    end
  end
  attr_accessor :promoted, :sente, :x, :y, :board

  def room_of_head?(x, y, name)
    true
  end

  def movable_grids
    return adjacent_movable_grids + far_movable_grids
  end

  def far_movable_grids
    return []
  end

  def jump_to?(x, y)
    if ((1 <= x) && (x <= 9) && (1 <= y) && (y <= 9))
      if ((@board.array[x][y] == nil) || # dst is empty
          (@board.array[x][y].sente != @sente)) # dst is enemy
        return true
      end
    end
    return false
  end

  def put_to?(x, y)
    if ((1 <= x) && (x <= 9) && (1 <= y) && (y <= 9))
      if (@board.array[x][y] == nil) # dst is empty?
        return true
      end
    end
    return false
  end

  def adjacent_movable_grids
    grids = Array::new
    if (@promoted)
      moves = @promoted_moves
    else
      moves = @normal_moves
    end
    moves.each do |(dx, dy)|
      if (@sente)
        cand_y = @y - dy
      else
        cand_y = @y + dy
      end
      cand_x = @x + dx
      if (jump_to?(cand_x, cand_y))
        grids.push([cand_x, cand_y])
      end
    end
    return grids
  end

  def move_to?(x, y, name)
    return false if (! room_of_head?(x, y, name))
    return false if ((name != @name) && (name != @promoted_name))
    return false if (@promoted && (name != @promoted_name)) # can't un-promote

    if (! @promoted)
      return false if (((@x == 0) || (@y == 0)) && (name != @name)) # can't put promoted piece
    end

    if ((@x == 0) || (@y == 0))
      return jump_to?(x, y)
    else
      return movable_grids.include?([x, y])
    end
  end

  def move_to(x, y)
    if ((@x == 0) || (@y == 0))
      if (@sente)
        @board.sente_hands.delete(self)
      else
        @board.gote_hands.delete(self)
      end
      @board.array[x][y] = self
    elsif ((x == 0) || (y == 0))
      @promoted = false         # clear promoted flag before moving to hands
      if (@sente)
        @board.sente_hands.push(self)
      else
        @board.gote_hands.push(self)
      end
      @board.array[@x][@y] = nil
    else
      @board.array[@x][@y] = nil
      @board.array[x][y] = self
    end
    @x = x
    @y = y
  end

  def point
    @point
  end

  def name
    @name
  end

  def promoted_name
    @promoted_name
  end

  def to_s
    if (@sente)
      sg = "+"
    else
      sg = "-"
    end
    if (@promoted)
      n = @promoted_name
    else
      n = @name
    end
    return sg + n
  end
  
  def to_sfen
    (@promoted ? "+" : "") + (@sente ? @sfen_name : @sfen_name.downcase)
  end

  def to_diag
    @promoted ? @promoted_name_jp : @name_jp
  end
end

class PieceFU < Piece
  def initialize(*arg)
    @point = 1
    @normal_moves = [[0, +1]]
    @promoted_moves = [[0, +1], [+1, +1], [-1, +1], [+1, +0], [-1, +0], [0, -1]]
    @name = "FU"
    @promoted_name = "TO"
    @sfen_name = "P"
    @name_jp = "歩"
    @promoted_name_jp = "と"
    super
  end
  def room_of_head?(x, y, name)
    if (name == "FU")
      if (@sente)
        return false if (y == 1)
      else
        return false if (y == 9)
      end
      ## 2fu check
      c = 0
      iy = 1
      while (iy <= 9)
        if ((iy  != @y) &&      # not source position
            @board.array[x][iy] &&
            (@board.array[x][iy].sente == @sente) && # mine
            (@board.array[x][iy].name == "FU") &&
            (@board.array[x][iy].promoted == false))
          return false
        end
        iy = iy + 1
      end
    end
    return true
  end
end

class PieceKY  < Piece
  def initialize(*arg)
    @point = 1
    @normal_moves = []
    @promoted_moves = [[0, +1], [+1, +1], [-1, +1], [+1, +0], [-1, +0], [0, -1]]
    @name = "KY"
    @promoted_name = "NY"
    @sfen_name = "L"
    @name_jp = "香"
    @promoted_name_jp = "杏"
    super
  end
  def room_of_head?(x, y, name)
    if (name == "KY")
      if (@sente)
        return false if (y == 1)
      else
        return false if (y == 9)
      end
    end
    return true
  end
  def far_movable_grids
    grids = Array::new
    if (@promoted)
      return []
    else
      if (@sente)                 # up
        cand_x = @x
        cand_y = @y - 1
        while (jump_to?(cand_x, cand_y))
          grids.push([cand_x, cand_y])
          break if (! put_to?(cand_x, cand_y))
          cand_y = cand_y - 1
        end
      else                        # down
        cand_x = @x
        cand_y = @y + 1
        while (jump_to?(cand_x, cand_y))
          grids.push([cand_x, cand_y])
          break if (! put_to?(cand_x, cand_y))
          cand_y = cand_y + 1
        end
      end
      return grids
    end
  end
end

class PieceKE  < Piece
  def initialize(*arg)
    @point = 1
    @normal_moves = [[+1, +2], [-1, +2]]
    @promoted_moves = [[0, +1], [+1, +1], [-1, +1], [+1, +0], [-1, +0], [0, -1]]
    @name = "KE"
    @promoted_name = "NK"
    @sfen_name = "N"
    @name_jp = "桂"
    @promoted_name_jp = "圭"
    super
  end
  def room_of_head?(x, y, name)
    if (name == "KE")
      if (@sente)
        return false if ((y == 1) || (y == 2))
      else
        return false if ((y == 9) || (y == 8))
      end
    end
    return true
  end
end
class PieceGI  < Piece
  def initialize(*arg)
    @point = 1
    @normal_moves = [[0, +1], [+1, +1], [-1, +1], [+1, -1], [-1, -1]]
    @promoted_moves = [[0, +1], [+1, +1], [-1, +1], [+1, +0], [-1, +0], [0, -1]]
    @name = "GI"
    @promoted_name = "NG"
    @sfen_name = "S"
    @name_jp = "銀"
    @promoted_name_jp = "全"
    super
  end
end
class PieceKI  < Piece
  def initialize(*arg)
    @point = 1
    @normal_moves = [[0, +1], [+1, +1], [-1, +1], [+1, +0], [-1, +0], [0, -1]]
    @promoted_moves = []
    @name = "KI"
    @promoted_name = nil
    @sfen_name = "G"
    @name_jp = "金"
    @promoted_name_jp = nil
    @promoted_name_diag = nil
    super
  end
end
class PieceKA  < Piece
  def initialize(*arg)
    @point = 5
    @normal_moves = []
    @promoted_moves = [[0, +1], [+1, 0], [-1, 0], [0, -1]]
    @name = "KA"
    @promoted_name = "UM"
    @sfen_name = "B"
    @name_jp = "角"
    @promoted_name_jp = "馬"
    super
  end
  def far_movable_grids
    grids = Array::new
    ## up right
    cand_x = @x - 1
    cand_y = @y - 1
    while (jump_to?(cand_x, cand_y))
      grids.push([cand_x, cand_y])
      break if (! put_to?(cand_x, cand_y))
      cand_x = cand_x - 1
      cand_y = cand_y - 1
    end
    ## down right
    cand_x = @x - 1
    cand_y = @y + 1
    while (jump_to?(cand_x, cand_y))
      grids.push([cand_x, cand_y])
      break if (! put_to?(cand_x, cand_y))
      cand_x = cand_x - 1
      cand_y = cand_y + 1
    end
    ## up left
    cand_x = @x + 1
    cand_y = @y - 1
    while (jump_to?(cand_x, cand_y))
      grids.push([cand_x, cand_y])
      break if (! put_to?(cand_x, cand_y))
      cand_x = cand_x + 1
      cand_y = cand_y - 1
    end
    ## down left
    cand_x = @x + 1
    cand_y = @y + 1
    while (jump_to?(cand_x, cand_y))
      grids.push([cand_x, cand_y])
      break if (! put_to?(cand_x, cand_y))
      cand_x = cand_x + 1
      cand_y = cand_y + 1
    end
    return grids
  end
end
class PieceHI  < Piece
  def initialize(*arg)
    @point = 5
    @normal_moves = []
    @promoted_moves = [[+1, +1], [-1, +1], [+1, -1], [-1, -1]]
    @name = "HI"
    @promoted_name = "RY"
    @sfen_name = "R"
    @name_jp = "飛"
    @promoted_name_jp = "龍"
    super
  end
  def far_movable_grids
    grids = Array::new
    ## up
    cand_x = @x
    cand_y = @y - 1
    while (jump_to?(cand_x, cand_y))
      grids.push([cand_x, cand_y])
      break if (! put_to?(cand_x, cand_y))
      cand_y = cand_y - 1
    end
    ## down
    cand_x = @x
    cand_y = @y + 1
    while (jump_to?(cand_x, cand_y))
      grids.push([cand_x, cand_y])
      break if (! put_to?(cand_x, cand_y))
      cand_y = cand_y + 1
    end
    ## right
    cand_x = @x - 1
    cand_y = @y
    while (jump_to?(cand_x, cand_y))
      grids.push([cand_x, cand_y])
      break if (! put_to?(cand_x, cand_y))
      cand_x = cand_x - 1
    end
    ## down
    cand_x = @x + 1
    cand_y = @y
    while (jump_to?(cand_x, cand_y))
      grids.push([cand_x, cand_y])
      break if (! put_to?(cand_x, cand_y))
      cand_x = cand_x + 1
    end
    return grids
  end
end
class PieceOU < Piece
  def initialize(*arg)
    @point = 0
    @normal_moves = [[0, +1], [+1, +1], [-1, +1], [+1, +0], [-1, +0], [0, -1], [+1, -1], [-1, -1]]
    @promoted_moves = []
    @name = "OU"
    @promoted_name = nil
    @sfen_name = "K"
    @name_jp = "玉"
    @promoted_name_jp = nil
    super
  end
end


end
