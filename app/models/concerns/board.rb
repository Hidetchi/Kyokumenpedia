require 'piece'

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
  end

  def empty
    initialize
  end

  # Set up a board with the strs.
  # Failing to parse the moves raises an StandardError.
  # @param strs a board text
  #
  def set_from_str(strs) #TODO define @sente_ou and @gote_ou
    strs.split("\n").each do |str|
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

  def set_from_sfen(sfen)
		tokens = sfen.split(" ")
		lines = tokens[0].split("/")
		y = 0
		promoted = false
		lines.each do |line|
			x = 9
			y += 1
			line.each_char do |s|
				if (s.match(/^\d$/))
					s.to_i.times do
						x -= 1
					end
				elsif (s == "+")
					promoted = true
			  else
			  	case (s.upcase)
					when "P"
						PieceFU::new(self, x, y, s == s.upcase, promoted)
					when "L"
						PieceKY::new(self, x, y, s == s.upcase, promoted)
					when "N"
						PieceKE::new(self, x, y, s == s.upcase, promoted)
					when "S"
						PieceGI::new(self, x, y, s == s.upcase, promoted)
					when "G"
						PieceKI::new(self, x, y, s == s.upcase, promoted)
					when "K"
						PieceOU::new(self, x, y, s == s.upcase, promoted)
					when "B"
						PieceKA::new(self, x, y, s == s.upcase, promoted)
					when "R"
						PieceHI::new(self, x, y, s == s.upcase, promoted)
					else
						raise "unkown piece #{s}"
					end
					x -= 1
					promoted = false
				end
			end
		end
		@teban = tokens[1] == "b"
		num = 1
		tokens[2].each_char do |s|
			if (s == "-")
				break
			elsif (s.match(/^\d$/))
				num = s.to_i
			else
				num.times do
			  	case (s.upcase)
					when "P"
						PieceFU::new(self, 0, 0, s == s.upcase)
					when "L"
						PieceKY::new(self, 0, 0, s == s.upcase)
					when "N"
						PieceKE::new(self, 0, 0, s == s.upcase)
					when "S"
						PieceGI::new(self, 0, 0, s == s.upcase)
					when "G"
						PieceKI::new(self, 0, 0, s == s.upcase)
					when "B"
						PieceKA::new(self, 0, 0, s == s.upcase)
					when "R"
						PieceHI::new(self, 0, 0, s == s.upcase)
					else
						raise "unkown piece #{s}"
					end
				end
				num = 1
			end
		end
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

  def num_candidates(x1, y1, name)
    num = 0
    for x in 1..9 do
      for y in 1..9 do
        num += 1 if (@array[x][y] && @array[x][y].to_s == name && @array[x][y].movable_grids.include?([x1, y1]))
      end
    end
    return num
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
    a.push(@teban ? "+" : "-")
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

  def handicap_id
	num = 0
	pieces = Hash.new(0)
	for y in 1..9 do
     for x in 1..9 do
	    if (@array[x][y])
         pieces[@array[x][y].name] += 1
         num += 1
       end
     end
	end
	(gote_hands + sente_hands).each do |p|
     pieces[p.name] += 1
     num += 1
   end
	if (num == 40)
		return 1
	elsif (num == 39)
		return 2 if pieces["KY"] == 3
		return 3 if pieces["KA"] == 1
		return 4 if pieces["HI"] == 1
	elsif (num == 38)
		return 5 if pieces["KY"] == 3
		return 6 if pieces["KA"] == 1
	elsif (num == 36)
		return 7
	elsif (num == 34)
		return 8
	elsif (num == 32)
		return 9
	end
	return nil
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

  def get_piece(x, y)
  	@array[x][y] ? @array[x][y].to_s : ""
  end

end
