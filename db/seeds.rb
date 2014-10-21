# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'json'

GameSource.create(:name => '81Dojo', :pass => 'shogi81', :kifu_url_header => 'http://81dojo.com/kifuviewer_jp.html?kid=', :category => 2)
Handicap.create(:id => 1, :name => 'Even')
Handicap.create(:id => 2, :name => 'Lance')
Handicap.create(:id => 3, :name => 'Bishop')
Handicap.create(:id => 4, :name => 'Rook')
Handicap.create(:id => 5, :name => 'Rook-lance')
Handicap.create(:id => 6, :name => '2-piece')
Handicap.create(:id => 7, :name => '4-piece')
Handicap.create(:id => 8, :name => '6-piece')
Handicap.create(:id => 9, :name => '8-piece')

strategy_file_path = './db/strategy_seeds.json'
file=File.read(strategy_file_path)
js_data = JSON.parse(file)

js_data["handicaps"].each do |handicap|
  board0 = ApplicationHelper::Board.new
  board0.initial(handicap["id"])
  handicap["families"].each do |family|
    family_record = StrategyFamily.create(:name => family["name"]) unless family_record = StrategyFamily.find_by(:name => family["name"])
    group_record = StrategyGroup.create(:name => '-', :strategy_family_id => family_record.id) unless group_record = StrategyGroup.find_by(:name => '-', :strategy_family_id => family_record.id)
    strategy_record = Strategy.create(:name => '-', :strategy_group_id => group_record.id) unless strategy_record = Strategy.find_by(:name => '-', :strategy_group_id => group_record.id)
    board1 = board0.do_moves_str(family["moves"])
    Position.create(:sfen => board1.to_sfen, :csa => board1.to_s, :handicap_id => handicap["id"], :strategy_id => strategy_record.id)
    
    family["groups"].each do |group|
      group_record = StrategyGroup.create(:name => group["name"], :strategy_family_id => family_record.id) unless group_record = StrategyGroup.find_by(:name => group["name"], :strategy_family_id => family_record.id)
      strategy_record = Strategy.create(:name => '-', :strategy_group_id => group_record.id) unless strategy_record = Strategy.find_by(:name => '-', :strategy_group_id => group_record.id)
      board2 = board1.do_moves_str(group["moves"])
      Position.create(:sfen => board2.to_sfen, :csa => board2.to_s, :handicap_id => handicap["id"], :strategy_id => strategy_record.id)
      
      group["branches"].each do |branch|
        strategy_record = Strategy.create(:name => branch["name"], :strategy_group_id => group_record.id) unless strategy_record = Strategy.find_by(:name => branch["name"], :strategy_group_id => group_record.id)
        board3 = board2.do_moves_str(branch["moves"])
        Position.create(:sfen => board3.to_sfen, :csa => board3.to_s, :handicap_id => handicap["id"], :strategy_id => strategy_record.id)
      end
    end
  end
end

