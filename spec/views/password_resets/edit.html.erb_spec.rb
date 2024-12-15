require 'rails_helper'

RSpec.describe "password_resets/edit.html.erb", type: :view do
  before do
    assign(:user, User.new(reset_password_token: "dummy_token"))
  end

  context "when there is no error flash message" do
    it "renders the video background" do
      render template: "password_resets/edit"
      expect(rendered).to have_selector('video.background-video')
      expect(rendered).to have_selector('source[src*="test.mov"][type="video/mp4"]')
    end

    it "displays the password reset form" do
      render template: "password_resets/edit"
      expect(rendered).to have_selector('form')
      expect(rendered).to have_field('user[password]', type: 'password', placeholder: "Enter your password")
      expect(rendered).to have_button('Reset Password')
    end

    it "displays the 'Password Reset' heading" do
      render template: "password_resets/edit"
      expect(rendered).to have_content("Password Reset")
    end
  end

  context "when there is an error flash message" do
    it "displays the error message" do
      flash[:reseterr] = "Invalid reset token"
      render template: "password_resets/edit"
      expect(rendered).to have_selector('.alert.alert-danger', text: "Invalid reset token")
    end

    it "does not display the password reset form" do
      flash[:reseterr] = "Invalid reset token"
      render template: "password_resets/edit"
      expect(rendered).not_to have_selector('form')
    end
  end
end
