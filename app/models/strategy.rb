class Strategy < ActiveRecord::Base
  has_many :positions
  belongs_to :main_position, class_name: 'Position', foreign_key: 'main_position_id'
  has_ancestry

  def self.user_ranking(strategy_id, limit = 10)
    #Returns an array of [ActiveRecord-user, sum-of-likes]
    strategy = Strategy.find(strategy_id)
    wikiposts = Wikipost.joins(:position).where('positions.strategy_id in (?)', strategy.subtree_ids)
    likes = Hash.new(0)
    wikiposts.each do |w|
      likes[w.user_id] += w.likes if w.likes > 0
    end
    likes = likes.sort_by{|k,v| -v}
    likes = likes[0..(limit-1)] if likes.length > limit
    user_ids = likes.map{|arr| arr[0]}
    sanitized_query = ActiveRecord::Base.send(:sanitize_sql_array, ["field(id ,?)",user_ids])
    users = User.where(id: user_ids).order(sanitized_query)
    i = 0
    users.each do |user|
      likes[i][0] = user
      i += 1
    end
    return likes
  end
end
