require 'rails_helper'

RSpec.describe "users/registrations/new.html.erb", type: :view do
  let(:user) { User.new }

  before do
    assign(:user, user)
  end

  it "displays the registration form correctly" do
    render

    # Check that the form tag is present and the form action is correct
    expect(rendered).to have_selector('form[action="/signup"]')

    # Check that the username input field is present
    expect(rendered).to have_selector("input[name='user[username]']")
    expect(rendered).to have_selector("input[placeholder='Enter your username']")

    # Check that the email input field is present
    expect(rendered).to have_selector("input[name='user[email]']")
    expect(rendered).to have_selector("input[placeholder='Enter your email']")

    # Check that the password field is present
    expect(rendered).to have_selector("input[name='user[password]']")
    expect(rendered).to have_selector("input[placeholder='Enter your password']")

    # Check that the password confirmation field is present
    expect(rendered).to have_selector("input[name='user[password_confirmation]']")
    expect(rendered).to have_selector("input[placeholder='Confirm your password']")

    # Check that the profile picture input field is present
    expect(rendered).to have_selector("input[type='file'][name='user[profile_picture]']")

    # Check that the submit button is present
    expect(rendered).to have_selector("input[type='submit'][value='Sign Up']")

    # Check that the background video is included
    expect(rendered).to have_selector('video.background-video')
  end

  it "displays error messages for invalid input" do
    # Simulate user input with errors
    user.username = ''
    user.email = 'invalid_email'
    user.password = 'short'
    user.password_confirmation = 'mismatch'
    user.valid? # Force validations

    render

    # Check that the username error is displayed
    expect(rendered).to have_selector('.alert.alert-danger', text: "can't be blank")

    # Check that the email error is displayed
    expect(rendered).to have_selector('.alert.alert-danger', text: "is invalid")

    # Check that the password error is displayed
    expect(rendered).to have_selector('.alert.alert-danger', text: "is too short")

    # Check that the password confirmation mismatch error is displayed
    expect(rendered).to have_selector('.alert.alert-danger', text: "Passwords do not match")
  end

  it "displays a password length requirement message" do
    render

    # Ensure the password requirement message is displayed
    expect(rendered).to have_selector('.centertip', text: 'Passwords must be 6+ characters long')
  end

  it "submits the form successfully with valid data" do
    # Set valid user data
    user.username = 'validuser'
    user.email = 'user@example.com'
    user.password = 'validpassword'
    user.password_confirmation = 'validpassword'

    # Simulate form submission
    expect {
      render
      # Simulate the form submission by filling out fields
      page.fill_in 'user[username]', with: user.username
      page.fill_in 'user[email]', with: user.email
      page.fill_in 'user[password]', with: user.password
      page.fill_in 'user[password_confirmation]', with: user.password_confirmation
      page.attach_file 'user[profile_picture]', 'spec/fixtures/files/sample_image.png'
      page.click_button 'Sign Up'
    }.to change(User, :count).by(1)  # Expect 1 user to be created

    # Verify redirection or success message after form submission
    expect(page).to have_current_path('/some_redirect_path')  # Replace with actual redirect path after successful signup
  end
end
