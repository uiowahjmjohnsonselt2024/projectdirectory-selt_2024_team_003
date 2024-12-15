require 'rails_helper'

RSpec.describe "login/reset_password.html.erb", type: :view do
  it "renders the video background" do
    render template: "login/reset_password"
    expect(rendered).to have_selector('video.background-video')
    expect(rendered).to have_selector('source[src*="test.mov"][type="video/mp4"]')
  end

  it "displays the password reset confirmation message" do
    render template: "login/reset_password"
    expect(rendered).to have_content("If this email has an account you will receive email with link to reset your password")
  end

  it "renders a link to the home page" do
    render template: "login/reset_password"
    expect(rendered).to have_link("Home", href: root_path)
  end
end
