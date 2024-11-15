require 'rails_helper'

RSpec.describe "home/index.html.haml", type: :view do
  before do
    assign(:welcome_message, "Welcome to Shards of the Grid!")
    assign(:login_button, "Login")
    assign(:create_button, "Create")
    assign(:copyright_text, "&copy; 2024 Shards of the Grid. All rights reserved.")
    render
  end

  it "displays the welcome message" do
    expect(rendered).to have_content("Welcome to Shards of the Grid!")
  end

  it "has a Login button" do
    expect(rendered).to have_link("Login", href: login_path)
  end

  it "has a Create Account button" do
    expect(rendered).to have_link("Create", href: create_path)
  end

  it "displays the copyright text" do
    expect(rendered).to have_content("© 2024 Shards of the Grid. All rights reserved.")
  end
end
