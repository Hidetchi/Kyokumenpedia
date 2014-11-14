require 'rails_helper'

RSpec.describe User, :type => :model do
  before :each do
    GameSource.create(:name => 'KifuProvider', :pass => 'rspec', :kifu_url_header => 'http://xxxxx.com/?kid=', :category => 2)
    Handicap.create(:id => 1, :name => 'Even')
  end
  describe "#to_result_mark" do
    context "when black won" do
      before do
        @game = Game.create(black_name: "Black", white_name: "White", date: "2014-01-01", csa: "+7776FU", handicap_id: 1, game_source_id: 1, result: 0)
      end
      it "shows win for black" do
        expect(@game.to_result_mark(true)).to eq("○")
      end
      it "shows loss for whie" do
        expect(@game.to_result_mark(false)).to eq("●")
      end
    end
    context "when white won" do
      before do
        @game = Game.create(black_name: "Black", white_name: "White", date: "2014-01-01", csa: "+7776FU", handicap_id: 1, game_source_id: 1, result: 1)
      end
      it "shows loss for black" do
        expect(@game.to_result_mark(true)).to eq("●")
      end
      it "shows win for white" do
        expect(@game.to_result_mark(false)).to eq("○")
      end
    end
    context "when draws" do
      before do
        @game = Game.create(black_name: "Black", white_name: "White", date: "2014-01-01", csa: "+7776FU", handicap_id: 1, game_source_id: 1, result: 2)
      end
      it "shows draw for black" do
        expect(@game.to_result_mark(true)).to eq("△")
      end
      it "shows draw for white" do
        expect(@game.to_result_mark(false)).to eq("△")
      end
    end
  end
end
