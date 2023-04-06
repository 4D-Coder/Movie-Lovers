# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Login Page', type: :feature do
  describe 'As a visitor,' do
    context "when I visit the login page '/login'" do
      before(:each) do
        @user = create(:user, password: Faker::Internet.password)
        visit login_path
      end

      it "When I enter my unique email and correct password, I'm taken to my dashboard page" do
        within('section#login_form') do
          fill_in :email, with: @user.email
          fill_in :password, with: @user.password
          
          click_button "Log In"
        end

        expect(current_path).to eq(user_path(@user.id))
        expect(page).to have_content("Welcome, #{@user.name}!")
      end

      it "enters bad credentials and is redirected back to the login with an error message" do
        within('section#login_form') do
          fill_in :email, with: @user.email
          fill_in :password, with: @user.password + "7"
          
          click_button "Log In"
        end
        
        expect(current_path).to eq(login_path)
        expect(page).to have_content("Bad login credentials, please try again.")
      end
    end
  end

  describe 'As a registered/logged in user' do
    context "when I visit the '/login' page" do
      before(:each) do
        @registered_user = create(:user, password: Faker::Internet.password, role: 1)
        visit login_path

        fill_in :email, with: @registered_user.email
        fill_in :password, with: @registered_user.password
        # Logging in with a before block until stubbing a login is better understood
      end
        
      it 'When I visit the landing page, I no longer see a link to Log In or Create an Account, But I see a link to Log Out.' do
        click_button 'Log In'
        click_link 'Home'

        expect(page).to have_link('Log Out')
        expect(page).to_not have_link('I already have an account')
        expect(page).to_not have_button('Create An Account')
      end
    end
  end
end