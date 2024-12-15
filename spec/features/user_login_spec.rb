require 'rails_helper'

RSpec.feature "UserLogins", type: :feature do
  scenario "User navigates to login page and sees login form" do
    visit login_button_path  # This is your login page path

    # Ensure the login form is visible and contains the correct fields
    expect(page).to have_content("Login")
    expect(page).to have_field('login', placeholder: 'Enter your username or email')
    expect(page).to have_field('password', placeholder: 'Enter your password')
    expect(page).to have_button('Login')

    # Check if the 'Create Account' link exists and navigates to the registration page
    expect(page).to have_link('Create Account', href: create_button_path)
    click_link('Create Account')
    expect(page).to have_content('Create Account')  # Ensure we are on the registration page

    # Check if the 'Forgot Password?' link exists and navigates to the password reset page
    visit login_button_path  # Navigate back to the login page
    expect(page).to have_link('Forgot Password?', href: password_resets_new_path)
    click_link('Forgot Password?')
  end

  scenario "User submits valid login credentials" do
    # Assuming you have a user created for testing purposes
    user = User.create!(email: 'test@example.com', username: 'testuser', password: 'password123', password_confirmation: 'password123')

    visit login_button_path

    fill_in 'login', with: user.email
    fill_in 'password', with: 'password123'
    click_button 'Login'

    # Expectation after login
    expect(page).to have_current_path(games_path)  # Assuming you redirect to the games path after successful login
  end

  scenario "User submits invalid login credentials" do
    visit login_button_path

    fill_in 'login', with: 'invaliduser'
    fill_in 'password', with: 'wrongpassword'
    click_button 'Login'

    # Expectation for invalid login
    expect(page).to have_content('Invalid login credentials.')
    expect(page).to have_current_path(login_button_path)  # Ensure we remain on the login page
  end
end
