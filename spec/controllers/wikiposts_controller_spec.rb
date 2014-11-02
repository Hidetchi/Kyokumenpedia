require 'rails_helper'

RSpec.describe WikipostsController, :type => :controller do
  before :all do
    @pos1 = FactoryGirl.create(:position)
    @user1 = FactoryGirl.create(:user)
    @wikipost1 = Wikipost.create(user_id: @user1.id, position_id: @pos1.id, content: "test1", comment: "comment1")
  end
  describe "#create" do
    context "when a new post is added" do
      before do
        hash = Hash.new
        hash[:content] = "test2 content"
        hash[:comment] = "sample comment"
        hash[:position_id] = @pos1.id
        hash[:user_id] = @user1.id
        hash[:minor] = false
        hash[:prev_post_id] = @wikipost1.id
        get 'create', :wikipost => hash
      end
      it "addes a new record" do
        expect(Wikipost.count).to eq(2)
      end
      it "sets latest_post_id to the position model" do
        expect(Wikipost.last.id).to eq(Position.last.latest_post_id)
      end
	end
  end
  after :all do
    Position.delete_all
    Wikipost.delete_all
    User.delete_all
  end
end
