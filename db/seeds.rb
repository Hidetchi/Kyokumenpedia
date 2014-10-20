# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

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

