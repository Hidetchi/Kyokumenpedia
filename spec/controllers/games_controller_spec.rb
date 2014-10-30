require 'rails_helper'

RSpec.describe GamesController, :type => :controller do
  describe "#create" do
    before do
      GameSource.create(:name => 'KifuProvider', :pass => 'rspec', :kifu_url_header => 'http://xxxxx.com/?kid=', :category => 2)
      Handicap.create(:id => 1, :name => 'Even')
      family = StrategyFamily.create(name: "Yokofudori")
      group = StrategyGroup.create(name: "-", strategy_family_id: family.id)
      strategy = Strategy.create(name: "-", strategy_group_id: group.id)
      lines = ["P1-KY-KE-GI-KI-OU * -GI-KE-KY",
               "P2 *  *  *  *  *  * -KI-KA * ",
               "P3-FU * -FU-FU-FU-FU *  * -FU",
               "P4 *  *  *  *  *  * +HI *  * ",
               "P5 *  *  *  *  *  *  *  *  * ",
               "P6 * -HI+FU *  *  *  *  *  * ",
               "P7+FU *  * +FU+FU+FU+FU * +FU",
               "P8 * +KA+KI *  *  *  *  *  * ",
               "P9+KY+KE+GI * +OU+KI+GI+KE+KY",
               "P+00FU00FU00FU", "P-00FU00FU", "-"]
      Position.create(handicap_id: 1, sfen: "lnsgk1snl/6gb1/p1pppp2p/6R2/9/1rP6/P2PPPP1P/1BG6/LNS1KGSNL w 3P2p", csa: lines.join("\n"), strategy_id: strategy.id)

      get :create, black_name: "player1", white_name: "player2", date: "2014-11-07", result: 1, handicap_id: 1, csa: "+7776FU-3334FU+2726FU-8384FU+2625FU-8485FU+6978KI-4132KI+2524FU-2324FU+2824HI-8586FU+8786FU-8286HI+2434HI-2233KA+3436HI-3122GI%TORYO", game_source_pass: "rspec"
    end
    
    context "with Yokofudori until -2233KA+3436HI-3122GI" do
      it "produces 19 positions" do
        expect(Position.count).to eq(19)
      end
      it "produces 19 moves" do
        expect(Move.count).to eq(19)
      end
      it "produces 19 appearances" do
        expect(Appearance.count).to eq(19)
      end
      it "increments stat_total in moves" do
        expect(Move.first.stat2_total).to eq(1)
      end
      it "increments stat_black/white in position" do
        expect(Position.first.stat2_white).to eq(1)
      end
      it "sets move number as num in appearance" do
        expect(Appearance.last.num).to eq(18)
      end
      it "gives the same strategy tag to all following positions once a strategy is given" do
        expect(Position.last.strategy.strategy_group.strategy_family.name).to eq("Yokofudori")
      end 
    end
    context "with duplicate kifu" do
      before do
        get :create, black_name: "player3", white_name: "player4", date: "2015-11-07", result: 1, handicap_id: 1, csa: "+7776FU-3334FU+2726FU-8384FU+2625FU-8485FU+6978KI-4132KI+2524FU-2324FU+2824HI-8586FU+8786FU-8286HI+2434HI-2233KA+3436HI-3122GI%TORYO", game_source_pass: "rspec"
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
