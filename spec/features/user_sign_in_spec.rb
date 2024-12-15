# spec/features/user_sign_in_spec.rb
require 'rails_helper'

RSpec.feature "UserRegistrations", type: :feature do
  scenario "user successfully creates an account" do
    visit signup_path

    fill_in 'Enter your username', with: 'testuser'
    fill_in 'Enter your email', with: 'testuser@example.com'
    fill_in 'Enter your password', with: 'password123'
    fill_in 'Confirm your password', with: 'password123'

    # If the file field for profile picture is required in the test:
    attach_file 'Profile Picture', 'path_to_test_image.jpg'  # Adjust as needed

    click_button 'Sign Up'

    expect(page).to have_content("Welcome, testuser")
  end
end