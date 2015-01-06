require 'rails_helper'

RSpec.describe PositionsController, :type => :controller do
  before :all do
    Position.delete_all
    @pos1 = Position.find_or_create("lns2g1nl/1r2gk1b1/pppppp1pp/9/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b SPb")
  end
  
  describe "#show" do
    context "when existing sfens (even with different handi-piece order) is sent" do
      it "renders show" do
        get 'show', :sfen1 => "lns2g1nl", :sfen2 => "1r2gk1b1", :sfen3 => "pppppp1pp", :sfen4 => "9", :sfen5 => "9", :sfen6 => "2P6", :sfen7 => "PP1PPPPPP", :sfen8 => "7R1", :sfen9 => "LNSGKGSNL b PSb"
        expect(response).to render_template('show')
      end
    end
    context "when a new proper sfens is sent" do
      it "renders show" do
        get 'show', :sfen1 => "lns2g1nl", :sfen2 => "1r2gk1b1", :sfen3 => "pppppp1pp", :sfen4 => "9", :sfen5 => "9", :sfen6 => "2P6", :sfen7 => "PPSPPPPPP", :sfen8 => "7R1", :sfen9 => "LNSGKGSNL b Pb"
        expect(response).to render_template('show')
      end
    end
    context "when wrong sfens is sent" do
      it "renders 404" do
        get 'show', :sfen1 => "lns2g1nl", :sfen2 => "1r2gk1b1", :sfen3 => "pppppp1pp", :sfen4 => "9", :sfen5 => "9", :sfen6 => "2P6", :sfen7 => "P2PPPPPP", :sfen8 => "7R1", :sfen9 => "LNSGKGSNL b SPb"
        expect(response).to render_template('404')
      end
    end
  end
  
  describe "#search" do
    it "renders search" do
      get 'search'
      expect(response).to render_template('search')
    end
  end
  
  describe "#post" do
    before do
      @pos1 = FactoryGirl.create(:position)
      @user1 = FactoryGirl.create(:user)
      @user1.confirm!
      hash = Hash.new
      hash[:content] = "test1 content"
      hash[:comment] = "sample comment"
      hash[:minor] = 0
      hash[:latest_post_id] = ""
      sign_in @user1
      post 'post', :id => @pos1.id, :wikipost => hash
      @wikipost1 = Wikipost.last
    end
    context "when a new post is added for the fist time" do
      it "addes a new record" do
        expect(Wikipost.count).to eq(1)
      end
      it "gives no prev_post_id" do
        expect(@wikipost1.prev_post_id).to eq(nil)
      end
      it "sets latest_post_id to the position model" do
        expect(@wikipost1.id).to eq(Position.last.latest_post_id)
      end
    end
    context "when a new post is added for the first time" do
      before do
        hash = Hash.new
        hash[:content] = "test2 content"
        hash[:comment] = "sample comment"
        hash[:minor] = 0 
        hash[:latest_post_id] = @wikipost1.id
        sign_in @user1
        post 'post', :id => @pos1.id, :wikipost => hash
      end
      it "addes a new record" do
        expect(Wikipost.count).to eq(2)
      end
      it "gives no prev_post_id" do
        expect(Wikipost.last.prev_post_id).to eq(@wikipost1.id)
      end
    end
  end
  after :all do
    Position.delete_all
    User.delete_all
  end
end
