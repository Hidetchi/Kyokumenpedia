require 'uri'
require 'open-uri'
require 'json'
require 'rexml/document'

class Shogidb2Entry < ActiveRecord::Base

# Result means kifu_post result
#   nil: no attempt
#   0: posted but failed due to invalid kifu
#   1: posted and successful
#   2: posted but duplicated
#   3: avoided posting (due to handicap level)
#   4: avoided posting (due to game importance (player level or lack of officiality))

def self.load_from_origin(with_register: true)
  180.step(0, -20) {|i|
    doc = REXML::Document.new(open("https://shogidb2.com/api/latest?limit=20&offset=" + i.to_s))
    data = doc.elements['/'].text
    h = JSON.load(data)
    h.reverse.each {|game|
      Shogidb2Entry.find_or_create_by(native_hash: game["hash"])
    }
    sleep(2)
  }
  Shogidb2Entry.register_all if with_register
end

def self.register_all
  Shogidb2Entry.where(result: nil).each {|e|
    e.register_kifu
    sleep(1)
  }
end

def register_kifu
  return if self.result != nil
  res = open('https://shogidb2.com/games/' + self.native_hash).read
  if res =~ /var\sdata\s\=\s(.+?)\;\<\/script\>/
    data = $1
    h=JSON.load(data)
    h["開始日時"] = "2014-11-01" if h["開始日時"] == nil
    if (h["棋戦"] == "アマ棋戦" || h["棋戦"] == "その他の棋戦" || h["棋戦"] == "電王戦")
      update_attributes(result: 4)
      return
    elsif (h["手合割"] != "平手")
      update_attributes(result: 3)
      return
    end
    csa_str = ""
    last_turn = 1
    result_code = nil
    h["moves"].each do |m|
      if (m["csa"] =~ /^\+/)
        last_turn = 0
      elsif (m["csa"] =~ /^\-/)
        last_turn = 1
      elsif (m["csa"] == "%TORYO")
        result_code = last_turn
      elsif (m["csa"] == "%SENNICHITE")
        result_code = 2
        m["csa"] = ""
      end
      csa_str += m["csa"]
    end
    hash = Hash[
      :native_kid => self.native_hash,
      :black_name => h["先手"],
      :white_name => h["後手"],
      :black_rate => "",
      :white_rate => "", 
      :date => h["開始日時"].split("T")[0],
      :result => result_code ? result_code : "",
      :csa => csa_str,
      :game_source_pass => "shogidb2",
      :event => h["棋戦詳細"],
      :handicap_id => 1
    ]
    params = ActionController::Parameters.new(hash)
    response = Game.save_after_validation(params)
    case response[:result]
    when /^Duplicate/
      update_attributes(result: 2)
    when /^Success/
      update_attributes(result: 1)
      puts self.id
    else
      update_attributes(result: 0)
      puts response[:result] + " " + self.native_hash
    end
  else
    update_attributes(result: 0)
    puts "Error " + self.native_hash
  end
end

end
