class Position < ActiveRecord::Base
  belongs_to :handicap
  belongs_to :strategy
  has_many :appearances
  has_many :games, through: :appearances
  has_many :prev_moves, class_name: 'Move', foreign_key: 'next_position_id'
  has_many :next_moves, class_name: 'Move', foreign_key: 'prev_position_id'
  has_many :prev_positions, :through => :prev_moves, :source => :prev_position
  has_many :next_positions, :through => :next_moves, :source => :next_position
  belongs_to :latest_post, class_name: 'Wikipost', foreign_key: 'latest_post_id'
  has_many :wikiposts, foreign_key: 'position_id'
  has_many :discussions, foreign_key: 'position_id'
  has_many :watches
  has_many :watchers, :through => :watches, :source => :user
  
  def self.find_or_create(sfen)
    board = Board.new
    return nil unless (board.set_from_sfen(sfen) == :normal)
    unless (position = Position.find_by(sfen: board.to_sfen))
      position = Position.create(:sfen => board.to_sfen, :handicap_id => board.handicap_id)
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
  
  def update_strategy(new_strategy)
    return self.strategy if (!new_strategy)
    if (!self.strategy_id || self.strategy.descendant_ids.include?(new_strategy.id))
  	  update_attributes(:strategy_id => new_strategy.id)
  	  return self.strategy
  	else
  	  return new_strategy
  	end
  end
  
  def to_board
    board = Board.new
    board.set_from_sfen(self.sfen)
    return board
  end  
end
