require 'diff/lcs'

class Wikipost < ActiveRecord::Base
  belongs_to :user
  belongs_to :position
  belongs_to :prev_post, class_name: 'Wikipost', foreign_key: 'prev_post_id'
  validates :position_id, :user_id, :content, :comment, presence: true
  
  def self.new_post(params)
    if (params[:prev_post_id] != "")
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
    lines1 = self.prev_post ? self.prev_post.content.split("\n") : ""
    lines2 = self.content.split("\n")
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
end
