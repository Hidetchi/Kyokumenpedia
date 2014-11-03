require 'rails_helper'

RSpec.describe Position, :type => :model do
  before :all do
    Position.delete_all
  	@pos1 = Position.find_or_create("lns2g1nl/1r2gk1b1/pppppp1pp/9/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b SPb")
  end
  describe "def find_or_create" do
  	context "when a new sfen is given" do
  	  it "adds a position to DB" do
  	  	expect(Position.count).to eq(1)
  	  end
  	  it "has correct piece locations on 2nd rank, for example" do
  	    expect(@pos1.csa.split("\n")[1]).to eq("P2 * -HI *  * -KI-OU * -KA * ")
  	  end
  	end
  	context "when a same position is given as sfen even with wrong hand-piece order" do
  	  before :all do
  	    @pos2 = Position.find_or_create("lns2g1nl/1r2gk1b1/pppppp1pp/9/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b PSb")
  	  end
  	  it "does not register it to DB" do
  	    expect(Position.count).to eq(1)
  	  end
  	  it "returns the same position from the DB" do
  	    expect(@pos2.id).to eq(@pos1.id)
  	  end
  	end
  end
  describe "def update_stat" do
    context "when category=2 result=1 is given" do
      it "increases stat2_white" do
        @pos1.update_stat(2, 1)
        pos = Position.find(@pos1.id)
        expect(pos.stat2_white).to eq(1)
      end
      it "increases stat2_white" do
        @pos1.update_stat(2, 1)
        pos = Position.find(@pos1.id)
        expect(pos.stat1_white).to eq(0)
      end
    end
  end
  describe "def update_strategy" do
    before :all do
      @strategy1 = Strategy.create(:name => "strategy1")
      @strategy2 = @strategy1.children.create(:name => "strategy2")
      @strategy3 = Strategy.create(:name => "strategy3")
    end
    context "when a strategy is sent for the first time" do
      it "updates the strategy" do
        @pos1.update_strategy(@strategy1)
        expect(@pos1.strategy_id).to eq(@strategy1.id)
      end
    end
    context "when a child strategy is sent" do
      it "updates the strategy" do
        @pos1.update_strategy(@strategy2)
        expect(@pos1.strategy_id).to eq(@strategy2.id)
      end
    end
    context "when a parent strategy is sent" do
      it "does not update the strategy" do
        @pos1.update_strategy(@strategy1)
        expect(@pos1.strategy_id).to eq(@strategy2.id)
      end
    end
    context "when a non-child strategy is sent" do
      it "does update the strategy" do
        @pos1.update_strategy(@strategy3)
        expect(@pos1.strategy_id).to eq(@strategy2.id)
      end
    end
  end
  after :all do
    Position.delete_all
    Strategy.delete_all
  end
end
