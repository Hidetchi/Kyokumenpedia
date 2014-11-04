require 'diff/lcs'

class Wikipost < ActiveRecord::Base
  belongs_to :user
  belongs_to :position
  belongs_to :prev_post, class_name: 'Wikipost', foreign_key: 'prev_post_id'
  validates :position_id, :user_id, :content, :comment, presence: true
  
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
  
  def to_past_time
    diff = Time.new - self.created_at
    if (diff > 3*365*24*60*60)
      return diff.div(365*24*60*60).to_s + "年前"
    elsif (diff > 2*30*24*60*60)
      return diff.div(24*60*60).to_s + "ヶ月前"
    elsif (diff > 24*60*60)
      return diff.div(24*60*60).to_s + "日前"
    elsif (diff > 60*60)
      return diff.div(60*60).to_s + "時間前"
    elsif (diff > 60)
      return diff.div(60).to_s + "分前"
    else
      return diff.to_i.to_s + "秒前"
    end
  end
end
