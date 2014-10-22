class Move < ActiveRecord::Base
  belongs_to :prev_position, class_name: 'Position', foreign_key: 'prev_position_id'
  belongs_to :next_position, class_name: 'Position', foreign_key: 'next_position_id'
  has_many :appearances
  
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
		kif += ["玉", "飛", "角", "金", "銀", "桂", "香", "歩", "", "龍", "馬", "", "全", "圭", "杏", "と"][type]
	end
  end   
end
