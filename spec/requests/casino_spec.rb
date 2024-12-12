require 'rails_helper'

RSpec.feature "CasinoGame", type: :feature do
  before do
    # Set up the user and the necessary session data
    @user = create(:user, shards: 100)  # Assuming you have a factory for User
    login_as(@user)  # Assuming you're using Devise or similar
    visit casino_path  # Adjust based on the actual path to the casino page
  end

  scenario "User sees their shard balance and navigates to store" do
    expect(page).to have_content("Your Shards: 100")
    click_link "Store"
    expect(page).to have_current_path(store_path)  # Adjust path if necessary
  end

  scenario "User places a bet and the spin result is displayed" do
    # Bet placement
    fill_in "bet_amount", with: 50
    click_button "Red"
    click_button "Spin"

    # Wait for the spinning animation and result
    expect(page).to have_content("Spinning...")
    expect(page).to have_content("You won!") # or "You lost!", depending on the result
    expect(page).to have_content("Your Shards: ")  # Ensure shard balance is updated
  end

  scenario "User cannot place a bet if they don't have enough shards" do
    @user.update(shards: 10)  # Set a low shard balance
    visit casino_path  # Reload the page

    fill_in "bet_amount", with: 50
    click_button "Red"
    click_button "Spin"

    expect(page).to have_content("Please enter a valid bet amount.")
  end
end
