require 'rails_helper'

RSpec.describe User, :type => :model do
  before :each do
    @user1 = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user, {username: 'user2', email: 'user2@is3.com'})
    @position = FactoryGirl.create(:position)
  end
  describe "follow" do
    context "when followed multiple times" do
      it "creates only 1 following_relatioin" do
        @user1.follow(@user2.id)
        @user1.follow(@user2.id)
        expect(Follow.count).to eq(1)
      end
    end
  end
  describe "unfollow" do
    context "when unfollowed" do
      it "destroys the following_relation" do
        @user1.follow(@user2.id)
        @user1.unfollow(@user2.id)
        expect(Follow.count).to eq(0)
      end
    end
    context "when unfollowed a non-following user" do
      it "escapes and nothing happens" do
        @user1.unfollow(@user2.id)
        expect(Follow.count).to eq(0)
      end
    end
  end
  describe "following?" do
    it "returns false when not following" do
      expect(@user1.following?(@user2.id)).to eq(false)
    end
    it "returns true when following" do
      @user1.follow(@user2.id)
      expect(@user1.following?(@user2.id)).to eq(true)
    end
  end
  describe "watch" do
    context "when watching multiple times" do
      it "creates only 1 watch" do
        @user1.watch(@position.id)
        @user1.watch(@position.id)
        expect(Watch.count).to eq(1)
      end
    end
  end
  describe "unwatch" do
    context "when unwatched" do
      it "destroys the watch" do
        @user1.unwatch(@position.id)
        @user1.unwatch(@position.id)
        expect(Watch.count).to eq(0)
      end
    end
    context "when unwatched a non-watching positioin" do
      it "escapes and nothing happens" do
        @user1.unwatch(@position.id)
        expect(Watch.count).to eq(0)
      end
    end
  end
  describe "watching?" do
    it "returns false when not watching" do
      expect(@user1.watching?(@position.id)).to eq(false)
    end
    it "returns true when watching" do
      @user1.watch(@position.id)
      expect(@user1.watching?(@position.id)).to eq(true)
    end
  end
end
