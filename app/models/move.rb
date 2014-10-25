class Move < ActiveRecord::Base
  include ApplicationHelper
  belongs_to :prev_position, class_name: 'Position', foreign_key: 'prev_position_id'
  belongs_to :next_position, class_name: 'Position', foreign_key: 'next_position_id'
  has_many :appearances

  def analyze
  	return if (prev_position_id == next_position_id)
	if (self.csa =~ /^([\+\-])(\d)(\d)(\d)(\d)([A-Z]{2})$/)
		sg = $1
		x0 = $2.to_i
		y0 = $3.to_i
		x1 = $4.to_i
		y1 = $5.to_i
		name = $6
	  	prev_board = Board.new
	  	prev_board.set_from_str(self.prev_position.csa)
	  	next_board = Board.new
	  	next_board.set_from_str(self.next_position.csa)
	  	self.promote = x0 != 0 && prev_board.get_piece(x0, y0) != next_board.get_piece(x1, y1)
		moved_piece_name = x0 == 0 ? (sg + name) : prev_board.get_piece(x0, y0)
	  	num = prev_board.num_candidates(x1, y1, moved_piece_name)
	  	self.vague = num > 1 || (num == 1 && x0 == 0)
	  	self.capture = prev_board.get_piece(x1, y1) != ""
	 end
  end

  def to_kif
	if (self.csa =~ /^([\+\-])(\d)(\d)(\d)(\d)([A-Z]{2})$/)
		sg = $1
		x0 = $2.to_i
		y0 = $3.to_i
		x1 = $4.to_i
		y1 = $5.to_i
		name = $6
		case (name)
			when "OU"
			  type = 0
			when "HI"
			  type = 1
			when "KA"
			  type = 2
			when "KI"
			  type = 3
			when "GI"
			  type = 4
			when "KE"
			  type = 5
			when "KY"
			  type = 6
			when "FU"
			  type = 7
			when "RY"
			  type = 9
			when "UM"
			  type = 10
			when "NG"
			  type = 12
			when "NK"
			  type = 13
			when "NY"
			  type = 14
			when "TO"
			  type = 15
		end
		kif = sg == "+" ? "▲" : "△"
		kif += ["０", "１", "２", "３", "４", "５", "６", "７", "８", "９"][x1]
		kif += ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"][y1]
		type -= 8 if (self.promote)
		kif += ["玉", "飛", "角", "金", "銀", "桂", "香", "歩", "", "龍", "馬", "", "成銀", "成桂", "成香", "と"][type]
		if (self.promote)
			kif += "成"
		elsif (x0 != 0 && (sg == "+" ? (y0 <= 3 || y1 <= 3) : (y0 >= 6 || y1 >= 6)) && type <= 7 && type != 0 && type != 3)
			kif += "不成"
		end
		if (self.vague)
			kif += x0 == 0 ? "打" : ("(" + x0.to_s + y0.to_s + ")")
		end
	elsif (self.csa == "%TORYO")
		kif = "投了"
	end
	return kif	
  end
end   
