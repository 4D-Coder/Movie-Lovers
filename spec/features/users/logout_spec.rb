# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Login Page', type: :feature do
  describe 'As a logged in user,' do
    before(:each) do
      @registered_user = create(:user, password: Faker::Internet.password, role: 1)
      visit login_path

      fill_in :email, with: @registered_user.email
      fill_in :password, with: @registered_user.password
      # Logging in with a before block until stubbing a login is better understood
    end
    
    context "when I visit the landing page '/'" do
      it "When I click 'Log Out' I'm taken to the landing page, and I can see that the 'Log Out' link has changed back to a Log In link" do
        click_button 'Log In'
        click_link 'Home'
        click_link 'Log Out'

        expect(current_path).to eq(root_path)
        expect(page).to have_link('I already have an account')
      end
    end
  end
end