require 'rails_helper'

RSpec.describe Move, :type => :model do
  before :all do
    @pos_initial = Position.create(handicap_id: 1, sfen: "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b -")
    @pos_7776FU = Position.create(handicap_id: 1, sfen: "lnsgkgsnl/1r5b1/ppppppppp/9/9/2P6/PP1PPPPPP/1B5R1/LNSGKGSNL w -")
    @pos_6152KI = Position.create(handicap_id: 1, sfen: "lns1kgsnl/1r2g2b1/ppppppppp/9/9/2P6/PP1PPPPPP/1B5R1/LNSGKGSNL b -")
    @pos_8833KA = Position.create(handicap_id: 1, sfen: "lns1kgsnl/1r2g2b1/ppppppBpp/9/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL w P")
    @pos_3142GI = Position.create(handicap_id: 1, sfen: "lns1kg1nl/1r2gs1b1/ppppppBpp/9/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b P")
    @pos_3342UM = Position.create(handicap_id: 1, sfen: "lns1kg1nl/1r2g+B1b1/pppppp1pp/9/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b SP")
    @pos_5142OU = Position.create(handicap_id: 1, sfen: "lns2g1nl/1r2gk1b1/pppppp1pp/9/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b SPb")
    @pos_0088GI = Position.create(handicap_id: 1, sfen: "lns2g1nl/1r2gk1b1/pppppp1pp/9/9/2P6/PP1PPPPPP/1S5R1/LNSGKGSNL b Pb")

    @move_7776FU = Move.create(:prev_position_id => @pos_initial.id, :next_position_id => @pos_7776FU.id, :csa => "+7776FU")
    @move_7776FU.analyze
    @move_6152KI = Move.create(:prev_position_id => @pos_7776FU.id, :next_position_id => @pos_6152KI.id, :csa => "-6152KI")
    @move_6152KI.analyze
    @move_8833KA = Move.create(:prev_position_id => @pos_6152KI.id, :next_position_id => @pos_8833KA.id, :csa => "+8833KA")
    @move_8833KA.analyze
    @move_3342UM = Move.create(:prev_position_id => @pos_3142GI.id, :next_position_id => @pos_3342UM.id, :csa => "+3342UM")
    @move_3342UM.analyze
    @move_0088GI = Move.create(:prev_position_id => @pos_5142OU.id, :next_position_id => @pos_0088GI.id, :csa => "+0088GI")
    @move_0088GI.analyze
  end

  describe "#find_or_new" do
		context "when existing move is set" do
			it "loads the existing move even if the csa_move is wrong" do
				expect{
    				move = Move.find_or_new(@pos_initial.id, @pos_7776FU.id, "+5756FU")
	    			move.save
				}.to change(Move, :count).by(0)
			end
		end
		context "when non-existing move is set" do
			it "creates a new record even if the move is not proper" do
				expect{
					move = Move.find_or_new(@pos_initial.id, @pos_6152KI.id, "+2726FU")
					move.save
				}.to change(Move, :count).by(1)
			end
		end
	end

	describe "#update_stat" do
		it "increases the stat_total for the corresponding category" do
		    stat = @move_7776FU.stat1_total
		    @move_7776FU.update_stat(1)
		    expect(@move_7776FU.stat1_total - stat).to be(1)
		end
		it "does not increase the stat_total for other categories" do
		    stat = @move_7776FU.stat2_total
		    @move_7776FU.update_stat(1)
		    expect(@move_7776FU.stat2_total - stat).to be(0)
		end
	end

  describe "#analyze" do
    context "with +7776FU" do
      it "sets self.promote = false" do
        expect(@move_7776FU.promote).to be(false)
      end
      it "sets self.vague = false" do
        expect(@move_7776FU.vague).to be(false)
      end
      it "sets self.capture = false" do
        expect(@move_7776FU.capture).to be(false)
      end
    end
    context "with -6152KI" do
      it "sets self.vague = true" do
        expect(@move_6152KI.vague).to be(true)
      end
    end
    context "with +8833KA" do
      it "sets self.capture = true" do
        expect(@move_8833KA.capture).to be(true)
      end
    end
    context "with +3342UM" do
      it "sets self.promote = true" do
        expect(@move_3342UM.promote).to be(true)
      end
    end
    context "with +0088GI" do
      it "sets self.vague = true" do
        expect(@move_0088GI.vague).to be(true)
      end
    end
  end
  
  describe "#to_kif" do
    context "with +7776FU" do
      it "produces 76fu" do
        expect(@move_7776FU.to_kif).to eq("▲７六歩")
      end
    end
    context "with -6152KI" do
      it "produces 52kin(61)" do
        expect(@move_6152KI.to_kif).to eq("△５二金(61)")
      end
    end
    context "with +8833KA" do
      it "produces 33kaku-narazu" do
        expect(@move_8833KA.to_kif).to eq("▲３三角不成")
      end
    end
    context "with +3342UM" do
      it "produces 42kaku-nari" do
        expect(@move_3342UM.to_kif).to eq("▲４二角成")
      end
    end
    context "with +0088GI" do
      it "produces 88gin-utsu" do
        expect(@move_0088GI.to_kif).to eq("▲８八銀打")
      end
    end
  end
  after :all do
    Position.delete_all
    Move.delete_all
  end
end
