require 'diff/lcs'

class Wikipost < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :user
  belongs_to :position
  belongs_to :prev_post, class_name: 'Wikipost', foreign_key: 'prev_post_id'
  validates :position_id, :user_id, :content, :comment, presence: true
  has_reputation :likes, source: :user, aggregated_by: :sum
  has_many :evaluations, class_name: "ReputationSystem::Evaluation", as: :target
  has_many :likers, :through => :evaluations, :source => :source, :source_type => 'User'
  paginates_per 50
  
  def self.new_post(params)
    if (params[:prev_post_id] && params[:prev_post_id] != "")
      prev_post = Wikipost.find(params[:prev_post_id])
      return false if (prev_post.content == params[:content])
    end
    begin
      wikipost = Wikipost.create!(params)
    rescue
      return false
    end
    wikipost.save_diff_nums
    wikipost.create_activity(action: 'create', owner: wikipost.user, recipient: wikipost.position)
    Headline.update("new", wikipost.position) if wikipost.prev_post_id == nil
    return wikipost
  end
  
  def diff_sets
    sets = []
    lines = self.prev_post ? self.prev_post.content.split("\n") : []
    lines1 = []
    lines.each do |line|
      lines1 << (line.chomp == "" ? "　" : line.chomp)
    end
    lines = self.content.split("\n")
    lines2 = []
    lines.each do |line|
      lines2 << (line.chomp == "" ? "　" : line.chomp)
    end    
    lineContextChanges = Diff::LCS.sdiff(lines1, lines2)
    lineContextChanges.each do |lcc|
      change = Hash[:line => lcc]
      if (lcc.action == "!")
        change[:chars] = Diff::LCS.sdiff(lcc.old_element, lcc.new_element)
      end
      sets << change
    end
    return sets
  end
  
  def to_local_time
  	time = self.created_at.localtime
  	time.strftime("%Y年%m月%d日 %H時%M分")
  end

  def save_diff_nums
    add = 0
    del = 0
    diff_sets.each do |set|
      case (set[:line].action)
      when "!"
        set[:chars].each do |change|
          if (change.action == "+")
            add += 1
          elsif (change.action == "-")
            del += 1
          elsif (change.action == "!")
            add += 1
            del += 1
          end
        end
      when "+"
        add += set[:line].new_element.length
      when "-"
        del += set[:line].old_element.length
      end
    end
    self.adds = add
    self.dels = del
    save
  end
  
  def reward_user
    if (self.prev_post_id == nil)
      if self.content.length >= 625
        point = 3
      elsif self.content.length >= 250
        point = 2
      elsif self.content.length >= 100
        point = 1
      else
        point = 0
      end
    elsif (self.minor && Wikipost.find(self.prev_post_id).user_id == self.user_id)
      point = 0
    else
      point = 1
    end
    self.user.point += point
    self.user.save
  end

  def tweet
    return unless (self.prev_post_id == nil && Rails.env.production?)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key       = TW_CONSUMER_KEY
      config.consumer_secret    = TW_CONSUMER_SECRET
      config.access_token        = TW_ACCESS_TOKEN
      config.access_token_secret = TW_ACCESS_SECRET
    end
    begin
      str = '【' + SITE_NAME + '】' + self.user.username + 'さんが新しい局面' + (self.position.strategy ? ('(' + self.position.strategy.name + ')') : '') + 'の解説を投稿しました。 http://kyokumen.jp/wikiposts/' + self.id.to_s + ' #shogi'
      client.update(str)
    rescue => e
      Rails.logger.error "Tweet.update ERROR : #{e.message}>>"
    end
  end
  
  def like(liker)
    return if liker.liked?(self)
    ActiveRecord::Base.transaction do
      self.add_evaluation(:likes, 1, liker)
      self.update_attributes(:likes => self.reputation_for(:likes).to_i)
      self.create_activity(action: 'like', owner: liker, recipient: self.user)
      User.increment_counter(:point, self.user_id)
    end
  end

  def unlike(liker)
    ActiveRecord::Base.transaction do
      if self.delete_evaluation(:likes, liker)
        self.update_attributes(:likes => self.reputation_for(:likes).to_i)
        User.decrement_counter(:point, self.user_id)
      end
    end
  end

  def update_references
    board = self.position.to_board
		lines = self.content.split("\n")
    sfens = []
    lines.each do |line|
			# Find {{Resemble|sfen|comment}}
			if (line =~ /^\s*\{\{Resemble\|(.+)\|(.+)\}\}\s*$/)
				sfens << $1
        next
			end
			# Find [[sfen-or-CSAmoves|text]]
			line = line.gsub(/\[{2}(.+?)\|(.+?)\]{2}/) {
				match1 = $1
				match2 = $2
        sfen = nil
				if (match1 =~ /^([\+\-]\d{4}[A-Z]{2})+$/)
          if (referred_board = board.do_moves_str(match1))
            sfen = referred_board.to_sfen 
          end
				elsif (match1 =~ /\A([\+1-9krbgsnlp]+\/){8}[\+1-9krbgsnlp]+\s[bw]\s[0-9rbgsnlp\-]+\z/i)
          sfen = match1
        end
        sfens << sfen if sfen
        ""
			}
    end
    position_ids = []
    sfens.each do |sfen|
      if (position = Position.find_or_create(sfen))
        position_ids << position.id
      end
    end
    positions = sfens.length > 0 ? Position.where(id: position_ids) : []
    self.position.referred_positions.replace(positions)
  end
  
  def keyword_neighbors(keyword)
    distance = 70
    i = self.content.index(keyword)
    return ["", ""] unless i
    if (i == 0)
      left = ""
    else
      i_min = i - distance
      i_min = 0 if (i_min < 0)
      left = self.content[i_min..(i-1)]
      left = "..... " + left if (i_min > 0)
    end
    i += (keyword.length - 1)
    if (i == self.content.length - 1)
      right == ""
    else
      i_max = i + distance
      i_max = self.content.length - 1 if (i_max >= self.content.length)
      right = self.content[(i+1)..i_max]
      right = right + " ....." if (i_max < self.content.length - 1)
    end
    [left, right]
  end
  
  def conclusion
    lines = self.content.split("\n")
    lines.each do |line|
      if (line =~ /^\s*\{\{Conclusion\|([^\|]+).*\}\}\s*$/)
        return $1
      end
    end
    return ""
  end
  
  def average_cp
    n = 0
    sum = 0
    lines = self.content.split("\n")
    lines.each do |line|
      if (line =~ /^\s*\{\{ComEval\|(.+)\|.+\|.+\|.*\}\}\s*$/)
        n += 1
        sum += $1.to_i
      end
    end
    if (n > 0)
      return (sum > 0 ? "+" : "") + (sum/n).to_s 
    else
      return ""
    end
  end

  def labels
    if !self.prev_post_id
      return "<span class='label' style='background-color:#35d;'>初版</span><br>"
    elsif self.prev_post.user_id == self.user_id
      return "<span class='label' style='background-color:#777;'>連投</span><br>"
    else
      return ""
    end
  end
end
