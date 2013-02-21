require 'spec_helper'

describe "PageContents" do
  
	subject{ page }

	describe "Home page" do
		before{ visit root_path }

		it{ should have_selector('title', text: 'PayWithMe')}
		it{ should_not have_selector('title', text: 'PayWithMe |')}

		it "should have proper links on the home page" do

			click_link "Register"
			# response.should have_selector('title', text: 'Register | PayWithMe')
			response.should have_selector('h2', content: 'Register')

			click_link "Login With Facebook"
			response.should have_selector('title', content: 'Facebook')

			click_link "Login With Twitter"
			response.should have_selector('title', content: 'Twitter')

			click_link "Login"
			response.should have_selector('h3', content: 'Welcome!')
		end
	end

	describe "Sign up" do
		before{ visit new_user_registration_path }

		it{ should have_selector('h2', text: 'Register') }

		let(:submit){ "Sign up" }

		describe "with invalid information" do

			it "should not create the user due to blank information" do
				expect{ click_button submit }.not_to change(User, :count)
			end

			it "should not create the user due to mismatching password" do
				
				fill_in "Name", 			with: "John Q Sample"
				fill_in "Email", 			with: "test@example.com"
				fill_in "Password", 		with: "foobarbaz"
				fill_in "Confirm Password", with: "mismatch"

				expect{ click_button submit }.not_to change(User, :count)
			end
			
			it "should not create the user due to no email" do
				
				fill_in "Name", 			with: "John Q Sample"
				fill_in "Email", 			with: ""
				fill_in "Password", 		with: "foobarbaz"
				fill_in "Confirm Password", with: "foobarbaz"

				expect{ click_button submit }.not_to change(User, :count)
			end

			it "should have a unique email address" do
				@user = FactoryGirl.create(:user)

				fill_in "Name", 			with: "Another Sample"
				fill_in "Email", 			with: "test@example.com"
				fill_in "Password", 		with: "foobarbaz"
				fill_in "Confirm Password", with: "foobarbaz"

				# expect{ click_button submit }.not_to change(User, :count)
			end
		end

		describe "with valid information" do
				
			it "should create the user" do
				
				fill_in "Name", 			with: "John Q Sample"
				fill_in "Email", 			with: "test@example.com"
				fill_in "Password", 		with: "foobarbaz"
				fill_in "Confirm Password", with: "foobarbaz"

				expect{ click_button submit }.to change(User, :count).by(1)
			end
		end
	end
end
