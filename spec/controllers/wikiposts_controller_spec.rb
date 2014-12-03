require 'rails_helper'

RSpec.describe WikipostsController, :type => :controller do
  before do
    @pos1 = FactoryGirl.create(:position)
    @user1 = FactoryGirl.create(:user)
  end
  describe "#create" do
    before do
      hash = Hash.new
      hash[:content] = "test1 content"
      hash[:comment] = "sample comment"
      hash[:minor] = 0
      hash[:latest_post_id] = ""
      sign_in @user1
      post 'create', :position_id => @pos1.id, :wikipost => hash
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
        post 'create', :position_id => @pos1.id, :wikipost => hash
      end
      it "addes a new record" do
        expect(Wikipost.count).to eq(2)
      end
      it "gives no prev_post_id" do
        expect(Wikipost.last.prev_post_id).to eq(@wikipost1.id)
      end
	end
  end
end
