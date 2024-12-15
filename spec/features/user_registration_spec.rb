# spec/features/user_registration_spec.rb

require 'rails_helper'

RSpec.feature "UserRegistrations", type: :feature do
  scenario "user successfully creates an account" do
    # Visit the registration page
    visit signup_path

    # Fill out the registration form
    fill_in 'Enter your username', with: 'testuser'
    fill_in 'Enter your email', with: 'testuser@example.com'
    fill_in 'Enter your password', with: 'password123'
    fill_in 'Confirm your password', with: 'password123'

    # Submit the form
    click_button 'Sign Up'

    # Expect the user to be redirected to the selections page
    expect(page).to have_current_path(selections_path)

    # Verify the flash message for successful registration
    expect(page).to have_content('Registration successful!')
  end
end
