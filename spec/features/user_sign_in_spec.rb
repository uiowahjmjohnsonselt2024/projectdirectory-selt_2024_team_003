# spec/features/user_sign_in_spec.rb
require 'rails_helper'

RSpec.feature "UserRegistrations", type: :feature do
  scenario "user successfully creates an account" do
    visit signup_path

    fill_in 'Enter your username', with: 'testuser'
    fill_in 'Enter your email', with: 'testuser@example.com'
    fill_in 'Enter your password', with: 'password123'
    fill_in 'Confirm your password', with: 'password123'


    click_button 'Sign Up'

    expect(page).to have_content("Welcome, testuser")
  end
end