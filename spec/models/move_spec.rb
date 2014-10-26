require 'rails_helper'

RSpec.describe Move, :type => :model do
  before do
    lines = ["P1-KY-KE-GI-KI-OU-KI-GI-KE-KY",
             "P2 * -HI *  *  *  *  * -KA * ",
             "P3-FU-FU-FU-FU-FU-FU-FU-FU-FU",
             "P4 *  *  *  *  *  *  *  *  * ",
             "P5 *  *  *  *  *  *  *  *  * ",
             "P6 *  *  *  *  *  *  *  *  * ",
             "P7+FU+FU+FU+FU+FU+FU+FU+FU+FU",
             "P8 * +KA *  *  *  *  * +HI * ",
             "P9+KY+KE+GI+KI+OU+KI+GI+KE+KY", "+"]
    @pos_initial = Position.create(handicap_id: 1, sfen: "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b -", csa: lines.join("\n"))
    lines = ["P1-KY-KE-GI-KI-OU-KI-GI-KE-KY",
             "P2 * -HI *  *  *  *  * -KA * ",
             "P3-FU-FU-FU-FU-FU-FU-FU-FU-FU",
             "P4 *  *  *  *  *  *  *  *  * ",
             "P5 *  *  *  *  *  *  *  *  * ",
             "P6 *  * +FU *  *  *  *  *  * ",
             "P7+FU+FU * +FU+FU+FU+FU+FU+FU",
             "P8 * +KA *  *  *  *  * +HI * ",
             "P9+KY+KE+GI+KI+OU+KI+GI+KE+KY", "-"]
    @pos_7776FU = Position.create(handicap_id: 1, sfen: "lnsgkgsnl/1r5b1/ppppppppp/9/9/2P6/PP1PPPPPP/1B5R1/LNSGKGSNL w -", csa: lines.join("\n"))
    lines = ["P1-KY-KE-GI * -OU-KI-GI-KE-KY",
             "P2 * -HI *  * -KI *  * -KA * ",
             "P3-FU-FU-FU-FU-FU-FU-FU-FU-FU",
             "P4 *  *  *  *  *  *  *  *  * ",
             "P5 *  *  *  *  *  *  *  *  * ",
             "P6 *  * +FU *  *  *  *  *  * ",
             "P7+FU+FU * +FU+FU+FU+FU+FU+FU",
             "P8 * +KA *  *  *  *  * +HI * ",
             "P9+KY+KE+GI+KI+OU+KI+GI+KE+KY", "+"]
    @pos_6152KI = Position.create(handicap_id: 1, sfen: "lns1kgsnl/1r2g2b1/ppppppppp/9/9/2P6/PP1PPPPPP/1B5R1/LNSGKGSNL b -", csa: lines.join("\n"))
    lines = ["P1-KY-KE-GI * -OU-KI-GI-KE-KY",
             "P2 * -HI *  * -KI *  * -KA * ",
             "P3-FU-FU-FU-FU-FU-FU+KA-FU-FU",
             "P4 *  *  *  *  *  *  *  *  * ",
             "P5 *  *  *  *  *  *  *  *  * ",
             "P6 *  * +FU *  *  *  *  *  * ",
             "P7+FU+FU * +FU+FU+FU+FU+FU+FU",
             "P8 *  *  *  *  *  *  * +HI * ",
             "P9+KY+KE+GI+KI+OU+KI+GI+KE+KY",
             "P+00FU", "-"]
    @pos_8833KA = Position.create(handicap_id: 1, sfen: "lns1kgsnl/1r2g2b1/ppppppBpp/9/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL w P", csa: lines.join("\n"))
    lines = ["P1-KY-KE-GI * -OU-KI * -KE-KY",
             "P2 * -HI *  * -KI-GI * -KA * ",
             "P3-FU-FU-FU-FU-FU-FU+KA-FU-FU",
             "P4 *  *  *  *  *  *  *  *  * ",
             "P5 *  *  *  *  *  *  *  *  * ",
             "P6 *  * +FU *  *  *  *  *  * ",
             "P7+FU+FU * +FU+FU+FU+FU+FU+FU",
             "P8 *  *  *  *  *  *  * +HI * ",
             "P9+KY+KE+GI+KI+OU+KI+GI+KE+KY",
             "P+00FU", "+"]
    @pos_3142GI = Position.create(handicap_id: 1, sfen: "lns1kg1nl/1r2gs1b1/ppppppBpp/9/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b P", csa: lines.join("\n"))
    lines = ["P1-KY-KE-GI * -OU-KI * -KE-KY",
             "P2 * -HI *  * -KI+UM * -KA * ",
             "P3-FU-FU-FU-FU-FU-FU * -FU-FU",
             "P4 *  *  *  *  *  *  *  *  * ",
             "P5 *  *  *  *  *  *  *  *  * ",
             "P6 *  * +FU *  *  *  *  *  * ",
             "P7+FU+FU * +FU+FU+FU+FU+FU+FU",
             "P8 *  *  *  *  *  *  * +HI * ",
             "P9+KY+KE+GI+KI+OU+KI+GI+KE+KY",
             "P+00FU00GI", "-"]
    @pos_3342UM = Position.create(handicap_id: 1, sfen: "lns1kg1nl/1r2g+B1b1/pppppp1pp/9/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b SP", csa: lines.join("\n"))
    lines = ["P1-KY-KE-GI *  * -KI * -KE-KY",
             "P2 * -HI *  * -KI-OU * -KA * ",
             "P3-FU-FU-FU-FU-FU-FU * -FU-FU",
             "P4 *  *  *  *  *  *  *  *  * ",
             "P5 *  *  *  *  *  *  *  *  * ",
             "P6 *  * +FU *  *  *  *  *  * ",
             "P7+FU+FU * +FU+FU+FU+FU+FU+FU",
             "P8 *  *  *  *  *  *  * +HI * ",
             "P9+KY+KE+GI+KI+OU+KI+GI+KE+KY",
             "P+00FU00GI", "P-00KA", "+"]
    @pos_5142OU = Position.create(handicap_id: 1, sfen: "lns2g1nl/1r2gk1b1/pppppp1pp/9/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b SPb", csa: lines.join("\n"))
    lines = ["P1-KY-KE-GI *  * -KI * -KE-KY",
             "P2 * -HI *  * -KI-OU * -KA * ",
             "P3-FU-FU-FU-FU-FU-FU * -FU-FU",
             "P4 *  *  *  *  *  *  *  *  * ",
             "P5 *  *  *  *  *  *  *  *  * ",
             "P6 *  * +FU *  *  *  *  *  * ",
             "P7+FU+FU * +FU+FU+FU+FU+FU+FU",
             "P8 * +GI *  *  *  *  * +HI * ",
             "P9+KY+KE+GI+KI+OU+KI+GI+KE+KY",
             "P+00FU", "P-00KA", "-"]
    @pos_0088GI = Position.create(handicap_id: 1, sfen: "lns2g1nl/1r2gk1b1/pppppp1pp/9/9/2P6/PP1PPPPPP/1S5R1/LNSGKGSNL b Pb", csa: lines.join("\n"))

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
end
