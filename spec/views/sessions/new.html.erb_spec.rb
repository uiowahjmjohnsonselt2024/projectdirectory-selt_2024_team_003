require 'rails_helper'

RSpec.feature "LoginPage", type: :feature do
  # Visit the login page
  before do
    visit login_path
  end

  scenario "User sees the login form with correct elements" do
    # Check that the video is present
    expect(page).to have_selector('video.background-video')

    # Check that the form contains the correct fields and placeholders
    expect(page).to have_field('login', placeholder: 'Enter your username or email')
    expect(page).to have_field('password', placeholder: 'Enter your password')

    # Check for the login button
    expect(page).to have_button('Login')

    # Check that the "Create Account" and "Forgot Password?" links are present
    expect(page).to have_link('Create Account', href: create_button_path)
    expect(page).to have_link('Forgot Password?', href: password_resets_new_path)
  end

  scenario "User submits form with empty fields" do
    # Submit the form with no input
    click_button 'Login'

    # Check for alert message
    expect(page).to have_css('.alert.alert-danger')
  end

  scenario "User sees the flash message" do
    # Simulate a flash alert
    flash[:alert] = "Invalid credentials"
    visit login_path

    # Check for the presence of flash alert
    expect(page).to have_css('.alert.alert-danger', text: "Invalid credentials")
  end
end
