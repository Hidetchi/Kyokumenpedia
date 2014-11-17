require 'rails_helper'

RSpec.describe GamesController, :type => :controller do
  describe "#create" do
    before do
      GameSource.create(:name => 'KifuProvider', :pass => 'rspec', :kifu_url_header => 'http://xxxxx.com/?kid=', :category => 2)
      Handicap.create(:id => 1, :name => 'Even')
      strategy = Strategy.create(name: "Yokofudori")
      strategy2 = strategy.children.create(name: "Yokofudori-henka")
      Position.create(handicap_id: 1, sfen: "lnsgk1snl/6gb1/p1pppp2p/6R2/9/1rP6/P2PPPP1P/1BG6/LNS1KGSNL w 3P2p", strategy_id: strategy.id)
      Position.create(handicap_id: 1, sfen: "lnsgk1snl/6g2/p1ppppb1p/9/9/1rP3R2/P2PPPP1P/1BG6/LNS1KGSNL w 3P2p", strategy_id: strategy2.id)
      Position.create(handicap_id: 1, sfen: "lnsg1k1nl/6gs1/p1ppppb1p/9/9/1rP4R1/P2PPPP1P/1BG6/LNS1KGSNL b 3P2p", strategy_id: strategy.id)

      get :create, black_name: "player1", white_name: "player2", date: "2014-11-07", result: 1, handicap_id: 1, csa: "+7776FU-3334FU+2726FU-8384FU+2625FU-8485FU+6978KI-4132KI+2524FU-2324FU+2824HI-8586FU+8786FU-8286HI+2434HI-2233KA+3436HI-3122GI+3626HI-5141OU%TORYO", game_source_pass: "rspec"
      Game.update_relations(Game.last.id)
    end
    
    context "with Yokofudori until -2233KA+3436HI-3122GI" do
      it "produces 21 positions" do
        expect(Position.count).to eq(21)
      end
      it "produces 21 moves" do
        expect(Move.count).to eq(21)
      end
      it "produces 21 appearances" do
        expect(Appearance.count).to eq(21)
      end
      it "increments stat_total in moves" do
        expect(Move.first.stat2_total).to eq(1)
      end
      it "increments stat_black/white in position" do
        expect(Position.first.stat2_white).to eq(1)
      end
      it "sets move number as num in appearance" do
        expect(Appearance.last.num).to eq(20)
      end
      it "gives the same strategy tag to no-strategy positions once a strategy is given" do
        expect(Position.find_by(sfen: "lnsgk1snl/6g2/p1ppppb1p/6R2/9/1rP6/P2PPPP1P/1BG6/LNS1KGSNL b 3P2p").strategy.name).to eq("Yokofudori")
      end 
      it "updates the current strategy if the position is already tagged" do
        expect(Position.find_by(sfen: "lnsgk2nl/6gs1/p1ppppb1p/9/9/1rP3R2/P2PPPP1P/1BG6/LNS1KGSNL b 3P2p").strategy.name).to eq("Yokofudori-henka")
      end 
      it "updates the position if the current strategy is a child of it" do
        expect(Position.last.strategy.name).to eq("Yokofudori-henka")
      end 
    end
    context "with duplicate kifu" do
      before do
        get :create, black_name: "player3", white_name: "player4", date: "2015-11-07", result: 1, handicap_id: 1, csa: "+7776FU-3334FU+2726FU-8384FU+2625FU-8485FU+6978KI-4132KI+2524FU-2324FU+2824HI-8586FU+8786FU-8286HI+2434HI-2233KA+3436HI-3122GI+3626HI-5141OU%TORYO", game_source_pass: "rspec"
      end      
      it "rejects a duplicate kifu" do
        expect(Game.count).to eq(1)
      end
      it "does not update stat_total in moves" do
        expect(Move.first.stat2_total).to eq(1)
      end
      it "does not update stat_black/white in position" do
        expect(Position.first.stat2_white).to eq(1)
      end
    end
    context "with no handicap_id" do
      it "rejects the kifu post" do
        expect{
          get :create, black_name: "player3", white_name: "player4", date: "2015-11-07", result: 1, csa: "+7776FU-3334FU%TORYO", game_source_pass: "rspec"
        }.to change(Game, :count).by(0)
      end
    end
    context "with invalid handicap_id" do
      it "rejects the kifu post" do
        expect{
          get :create, black_name: "player3", white_name: "player4", date: "2015-11-07", result: 1, handicap_id: 2, csa: "+7776FU-3334FU%TORYO", game_source_pass: "rspec"
        }.to change(Game, :count).by(0)
      end
    end
    context "with no game_source_pass" do
      it "rejects the kifu post" do
        expect{
          get :create, black_name: "player3", white_name: "player4", date: "2015-11-07", result: 1, handicap_id: 1, csa: "+7776FU-3334FU%TORYO"
        }.to change(Game, :count).by(0)
      end
    end
    context "with invalid game_source_pass" do
      it "rejects the kifu post" do
        expect{
          get :create, black_name: "player3", white_name: "player4", date: "2015-11-07", result: 1, handicap_id: 1, csa: "+7776FU-3334FU%TORYO", game_source_pass: "xxxx"
        }.to change(Game, :count).by(0)
      end
    end
  end
end
