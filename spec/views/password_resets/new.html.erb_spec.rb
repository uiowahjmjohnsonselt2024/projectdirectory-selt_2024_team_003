require 'rails_helper'

RSpec.describe "password_resets/new.html.erb", type: :view do
  before do
    # Simulate any necessary variables or conditions
  end

  context "when rendering the page" do
    it "renders the video background" do
      render
      expect(rendered).to have_selector('video.background-video')
      expect(rendered).to have_selector('source[src*="test.mov"][type="video/mp4"]')
    end

    it "displays the password reset form" do
      render
      expect(rendered).to have_selector('form[action="/password_resets"][method="post"]')
      expect(rendered).to have_field('email', type: 'text', placeholder: 'Enter your email')
      expect(rendered).to have_button('Send password reset instructions')
    end

    it "displays the 'Forgot your password?' heading" do
      render
      expect(rendered).to have_content('Forgot your password?')
    end
  end

  context "when a flash alert is present" do
    it "displays the alert message" do
      flash[:alert] = "Invalid email address"
      render
      expect(rendered).to have_selector('.alert.alert-danger', text: 'Invalid email address')
    end
  end

  context "when no flash alert is present" do
    it "does not display an alert message" do
      render
      expect(rendered).not_to have_selector('.alert.alert-danger')
    end
  end
end
