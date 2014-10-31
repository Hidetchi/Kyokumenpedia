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
  
  after :all do
    Position.delete_all
  end
end
