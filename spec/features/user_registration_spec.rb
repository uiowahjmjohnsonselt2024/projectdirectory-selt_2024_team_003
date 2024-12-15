# spec/features/user_registration_spec.rb

require 'rails_helper'

RSpec.feature "UserRegistrations", type: :feature do
  scenario "user successfully creates an account" do
    # Visit the registration page
    visit signup_path

    # Fill out the registration form
    fill_in 'user[username]', with: 'testuser'
    fill_in 'user[email]', with: 'testuser@example.com'
    fill_in 'user[password]', with: 'password123'
    fill_in 'user[password_confirmation]', with: 'password123'

    # Attach a file for the profile picture
    attach_file 'user[profile_picture]', Rails.root.join('spec/fixtures/files/profile_picture.jpg')

    # Submit the form
    click_button 'Sign Up'

    # Expect the user to be redirected to the selections page
    expect(page).to have_current_path(selections_path)

    # Verify the flash message for successful registration
    expect(page).to have_content('Registration successful!')
  end
end
