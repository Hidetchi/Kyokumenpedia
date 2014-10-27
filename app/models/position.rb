class Position < ActiveRecord::Base
  belongs_to :handicap
  belongs_to :strategy
  has_many :appearances
  has_many :games, through: :appearances
  has_many :prev_moves, class_name: 'Move', foreign_key: 'next_position_id'
  has_many :next_moves, class_name: 'Move', foreign_key: 'prev_position_id'
  has_many :prev_positions, :through => :prev_moves, :source => :prev_position
  has_many :next_positions, :through => :next_moves, :source => :next_position
  
  def self.find_or_create(sfen, csa, handicap_id)
    unless (position = Position.find_by(sfen: sfen))
      position = Position.create(:sfen => sfen, :csa => csa, :handicap_id => handicap_id)
    end
    return position
  end

  def update_stat(category, result)
    if (category == 1)  # Official professional kifu
      if (result == 0) 
        self.stat1_black += 1
      elsif (result == 1)
        self.stat1_white += 1
      elsif (result == 2)
        self.stat1_draw += 1
      end
    elsif (category == 2)  # Amateur online games
      if (result == 0) 
        self.stat2_black += 1
      elsif (result == 1)
        self.stat2_white += 1
      elsif (result == 2)
        self.stat2_draw += 1
      end
    end
    save
  end
end
