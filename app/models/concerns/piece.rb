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
  
  def to_bod
    (@sente ? " " : "v") + to_diag
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
