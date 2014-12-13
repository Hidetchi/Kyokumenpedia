# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'yaml'

def register_strategy(new_node, parent)
	if (parent)
		strategy = parent.children.create(:name => new_node["name"])
	else
		strategy = Strategy.create(:name => new_node["name"])
	end
  if new_node["sfens"]
    new_node["sfens"].each do |sfen|
      position = Position.find_or_create(sfen)
      position.overwrite_strategy(strategy)
    end
  end
  if new_node["children"]
    new_node["children"].each do |child|
      register_strategy(child, strategy)
    end
  end
end


GameSource.create(:name => 'JSA', :pass => 'jsa', :kifu_url_header => '', :category => 1)
GameSource.create(:name => '81Dojo', :pass => 'shogi81', :kifu_url_header => 'http://81dojo.com/kifuviewer_jp.html?kid=', :category => 2)
GameSource.create(:name => 'floodgate', :pass => 'flood', :kifu_url_header => 'http://wdoor.c.u-tokyo.ac.jp/shogi/view/', :kifu_url_footer => '.csa', :category => 3)
Handicap.create(:id => 1, :name => '平手')
Handicap.create(:id => 2, :name => '香落ち')
Handicap.create(:id => 3, :name => '角落ち')
Handicap.create(:id => 4, :name => '飛車落ち')
Handicap.create(:id => 5, :name => '飛香落ち')
Handicap.create(:id => 6, :name => '二枚落ち')
Handicap.create(:id => 7, :name => '四枚落ち')
Handicap.create(:id => 8, :name => '六枚落ち')
Handicap.create(:id => 9, :name => '八枚落ち')

yaml_data = YAML.load_file("./db/strategy_seeds.yml")
yaml_data["roots"].each do |root|
	register_strategy(root, nil)
end



