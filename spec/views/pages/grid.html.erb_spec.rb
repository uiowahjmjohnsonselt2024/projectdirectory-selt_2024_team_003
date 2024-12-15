require 'rails_helper'
require 'ostruct'

RSpec.describe "pages/grid.html.erb", type: :view do
  before do
    # Mock current user
    @current_user = User.create!(username: "TestUser", email: "testuser@example.com", password: "password123", level: 10)
  
    view.singleton_class.class_eval do
      def current_user
        User.find_by(username: "TestUser")
      end
    end
  
    allow(view).to receive(:current_user).and_return(@current_user)
  
    # Mock game
    assign(:game, OpenStruct.new(code: "GAME"))
  
    # Mock user data
    assign(:user_name, "TestUser")
    assign(:current_experience, 50)
    assign(:experience_for_next_level, 100)
    assign(:current_health, 80)
    assign(:max_health, 100)
    assign(:current_mana, 30)
    assign(:max_mana, 50)
  
    # Mock stats
    assign(:stats, [
      { name: "Attack", value: 15 },
      { name: "Defense", value: 10 }
    ])
  
    # Mock current game user
    assign(:current_game_user, OpenStruct.new(x_position: 2, y_position: 3))
  
    # Mock adjacent tiles
    assign(:adjacent_tiles, [
      { x: 1, y: 3 },
      { x: 3, y: 3 },
      { x: 2, y: 4 }
    ])
  
    # Mock other players
    other_user = User.create!(username: "Player1", email: "player1@example.com", password: "password123")
    assign(:players, [
      OpenStruct.new(user: other_user, x_position: 4, y_position: 5)
    ])
  end  

  it "renders the return to menu button" do
    render
    expect(rendered).to have_link("Return to Menu", href: games_path, class: "red-button")
  end

  it "renders the user profile section" do
    render
    expect(rendered).to have_selector(".profile-picture-placeholder img.user-avatar")
    expect(rendered).to have_content("TestUser")
    expect(rendered).to have_content("Level: 10")
  end

  it "renders progress bars for experience, health, and mana" do
    render
    expect(rendered).to have_selector("#player-experience", visible: false)
    expect(rendered).to have_selector("#player-health", visible: false)
    expect(rendered).to have_selector("#player-mana", visible: false)
  end

  it "renders user stats" do
    render
    expect(rendered).to have_selector(".stat-name", text: "Attack:")
    expect(rendered).to have_selector(".stat-value", text: "15")
    expect(rendered).to have_content("Current Position: (2, 3)")
  end  

  it "renders the grid with 36 squares" do
    render
    expect(rendered).to have_selector(".grid-square", count: 36)
  end  

  it "renders the player list with avatars and usernames" do
    render
    expect(rendered).to have_selector(".player-list .player", count: 1)
    expect(rendered).to have_content("Player1")
    expect(rendered).to have_content("Current Position: (4, 5)")
  end

  it "renders grid squares with data-description attributes for tooltips" do
    render
    expect(rendered).to have_selector(".grid-square[data-description]", count: 36)
  end  
end