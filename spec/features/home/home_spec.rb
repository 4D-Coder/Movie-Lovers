# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Site Home Page:', type: :feature do
  describe 'As a visitor,' do
    context "when I visit the root path ('/')" do
      before(:each) do
        @user1 = create(:user)

        visit root_path
      end

      it 'has a Link to go back to the landing page' do
        within 'nav#navigation' do
          expect(page).to have_link('Home')
        end
      end

      it 'includes Title of Application, a button to create an account, and a link to log in' do
        within 'header#title' do
          expect(page).to have_content('Viewing Party')
        end
        
        within 'section#users' do
          expect(page).to have_button('Create An Account')
        end

        within 'section#users' do
          expect(page).to have_link('I already have an account')
        end
      end

      it "has a link 'I already have an account', and when I click on it, I'm taken to a Log In page ('/login') where I can input my unique email and password." do
        within 'section#users' do
          click_link 'I already have an account'
        end

        expect(current_path).to eq(login_path)

        within('section#login_form') do
          expect(page).to have_field('E-mail')
          expect(page).to have_field('Password')
          expect(page).to have_button('Log In')
        end
      end

      it 'has a link to create an account, I click it and I am taken to a registry form' do
        within('section#users') do
          expect(page).to have_button("Create An Account")

          click_button "Create An Account"
        end

        expect(current_path).to eq(register_path)
      end

      it 'I do not see the section of the page that lists registered users' do
        expect(page).to_not have_css('section#registered_users')
      end

      it "tries to visit /dashboard and remains on the landing page, yeilding an error message" do
        visit user_path(@user1.id)

        expect(current_path).to eq(root_path)
        expect(page).to have_content("You must be logged in or registered to access your dashboard.")
      end

      it "tries to visit movie show page and is redirected to the landing page, yeilding an error message" do
        VCR.use_cassette('movie_details', serialize_with: :json, match_requests_on: [:method, :path]) do
          cocaine_bear = MovieFacade.new.movie_details(804150)

          visit user_movie_path(@user1.id, cocaine_bear.id)

          expect(current_path).to eq(root_path)
          expect(page).to have_content("You must be logged in or registered to access your dashboard.")
        end
      end
    end
  end

  describe 'as a registered user' do
    context "when I visit the root path ('/')," do
      before(:each) do
        @fake_password = Faker::Internet.password
        @user1 = create(:user, password: @fake_password, role: 1)
        @user2 = create(:user, password: @fake_password, role: 1)
        @user3 = create(:user, password: @fake_password, role: 1)

        visit login_path

        fill_in :email, with: @user1.email
        fill_in :password, with: @fake_password

        click_button "Log In"
        click_link "Home"
      end

      it 'The list of registered users is a list of email addresses' do

        within "div#user-#{@user1.id}" do
          expect(page).to have_content(@user1.email)
        end

        within "div#user-#{@user2.id}" do
          expect(page).to have_content(@user2.email)
        end

        within "div#user-#{@user3.id}" do
          expect(page).to have_content(@user3.email)
        end
      end
    end
  end
end
