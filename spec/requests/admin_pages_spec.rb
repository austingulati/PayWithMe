require 'spec_helper'

describe "Admin" do

  subject { page }
  # let(:pages) { [:index, :events, :users, :groups, :statistics] }
  # pages = [:index, :users, :events, :groups]
  pages = [:users, :events, :groups]

  describe "not signed in" do
    pages.each do |page|
      before { visit send("#{page}_admin_index_path") }
      it "should redirect to login page" do
        should have_selector("h2", text: "Sign in")
        should have_selector("title", text: "Sign in")
      end
    end
  end

  describe "not admin user" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    pages.each do |page|
      before { visit send("#{page}_admin_index_path") }
      it "should redirect to index page" do
        should have_selector("h2", text: "News Feed")
        should have_selector("title", text: "PayWithMe")
      end
    end
  end

  describe "as admin user" do
    before do
      @user = FactoryGirl.create(:admin_user)
      sign_in @user
    end

    pages.each do |page|
      before { visit send("#{page}_admin_index_path") }
      it "should render page" do
        should have_selector("title", text: "Administrator Panel")
      end
    end
  end

end