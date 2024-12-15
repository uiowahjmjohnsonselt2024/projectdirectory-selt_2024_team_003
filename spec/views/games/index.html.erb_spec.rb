require 'rails_helper'

RSpec.describe "games/index.html.erb", type: :view do
  before do
    # Define `current_user` in the view context
    @user = User.new(username: "Test User")
    view.singleton_class.class_eval do
      def current_user
        User.new(username: "Test User")
      end
    end

    # Assign a dummy list of games
    assign(:games, [
      Game.new(name: "Game 1", code: "ABCD"),
      Game.new(name: "Game 2", code: "EFGH")
    ])
  end

  it "displays the current user's profile picture or default avatar" do
    render
    expect(rendered).to have_selector("img.user-avatar") # Checks for profile picture image tag
  end

  it "displays navigation buttons" do
    render
    expect(rendered).to have_link("Logout", href: logout_path)
    expect(rendered).to have_link("Shop", href: store_path)
    expect(rendered).to have_link("Account", href: account_path)
    expect(rendered).to have_link("Credit Card", href: credit_card_redirect_path)
  end

  it "displays the form for creating a new game" do
    render
    expect(rendered).to have_selector("form[action='#{games_path}'][method='post']")
    expect(rendered).to have_selector("label", text: "Game Name:") # Form label
    expect(rendered).to have_selector("input[name='game[name]']") # Input field
    expect(rendered).to have_button("Create Game") # Submit button
  end

  it "displays the form for joining a game" do
    render
    expect(rendered).to have_selector("form[action='#{join_games_path}'][method='post']")
    expect(rendered).to have_selector("label", text: "Game Code:") # Form label
    expect(rendered).to have_selector("input[name='code']") # Input field
    expect(rendered).to have_button("Join Game") # Submit button
  end

  it "displays a list of games with name and code" do
    render
    expect(rendered).to have_selector("h3", text: "Games List") # List header
    expect(rendered).to have_selector("ul") # Unordered list
    expect(rendered).to have_selector("li", text: "Name: Game 1 | Code: ABCD") # First game
    expect(rendered).to have_selector("li", text: "Name: Game 2 | Code: EFGH") # Second game
  end
end