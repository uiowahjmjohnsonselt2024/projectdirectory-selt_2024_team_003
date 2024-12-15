require 'rails_helper'

RSpec.feature "Grid page", type: :feature do
  let(:user) { create(:user) }
  let(:game) { create(:game, code: 'GAME123') }
  let(:skin) { create(:skin) }  # Create a skin, assuming Skin is a separate model
  let(:game_user) { create(:game_user, user: user, game: game, x_position: 0, y_position: 0, current_skin: skin) }

  before do
    user.game_users << game_user
    game.game_users << game_user
    session[:user_id] = user.id  # Assuming you're using Devise for authentication
    visit grid_path  # Visit the grid page
  end

  scenario "Player sees their avatar, username, and health info" do
    expect(page).to have_css('.user-avatar')
    expect(page).to have_content(user.username)
    expect(page).to have_content("Health: #{@current_health} / #{@max_health}")
    expect(page).to have_content("XP: #{@current_experience} / #{@experience_for_next_level}")
  end

  scenario "Grid squares are displayed" do
    expect(page).to have_css('.grid-row')
    expect(page).to have_css('.grid-square', count: 36)  # 6 rows x 6 columns
  end

  scenario "Clicking an adjacent grid tile updates the player's position" do
    adjacent_tile = find('[data-x="1"][data-y="0"]')  # Right of (0,0)
    adjacent_tile.click
    expect(page).to have_content('Move successful')  # Customize based on your response
    expect(page).to have_css('.current-position', text: "(1, 0)")  # Verify new position
  end

  scenario "Clicking a non-adjacent grid tile triggers a shard cost confirmation" do
    non_adjacent_tile = find('[data-x="3"][data-y="3"]')  # Far from (0,0)
    non_adjacent_tile.click
    expect(page).to have_content("Move to this square for 10 shards?")
  end

  scenario "Tooltips display correct information on hover" do
    grid_square = find('[data-x="0"][data-y="0"]')  # Top-left square
    grid_square.hover
    expect(page).to have_css('.tooltip', text: 'An astronaut on a mission. (0, 0)')
  end

  scenario "Player health bar color changes based on health" do
    game_user.update(health: 5, max_health: 20)  # Set low health for the test
    visit grid_path  # Reload the page
    health_bar = find('#player-health')
    expect(health_bar[:style]).to include('background-color: red')
  end
end
