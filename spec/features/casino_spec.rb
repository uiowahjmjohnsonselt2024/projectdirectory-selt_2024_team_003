require 'rails_helper'

RSpec.feature 'Casino Feature', type: :feature do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:skin) { create(:skin) }  # Assuming there's a Skin model

  before do
    # Create the game_user association
    create(:game_user, user: user, game: game)

    # Assign a current skin to the user
    user.update(current_skin: skin)

    # Authenticate the user by setting the user_id in the session
    session[:user_id] = user.id

    # Visit the casino page
    visit casino_path
  end

  scenario 'User places a bet and wins, shards are updated' do
    # Visit the casino page
    visit casino_path

    # Ensure the initial shard count is displayed
    initial_shards = user.shards
    expect(page).to have_content("Your Shards: #{initial_shards}")

    # Fill in the bet amount and select a color
    fill_in 'bet_amount', with: 50
    find('.bet-button.red').click

    # Expect the spin button to be enabled and click it
    expect(page).to have_button('Spin')
    click_button 'Spin'

    # Wait for the result to appear
    expect(page).to have_css('#result', text: /You (won|lost)!/)

    # Check if the shard count has been updated correctly
    new_shards = initial_shards + 50 * 2  # Assuming red has a 2x payout
    expect(page).to have_content("Your Shards: #{new_shards}")
  end

  scenario 'User places a bet and loses, shards are updated' do
    # Visit the casino page
    visit casino_path

    # Ensure the initial shard count is displayed
    initial_shards = user.shards
    expect(page).to have_content("Your Shards: #{initial_shards}")

    # Fill in the bet amount and select a color
    fill_in 'bet_amount', with: 50
    find('.bet-button.red').click

    # Simulate a losing spin (we need to force a loss for this test)
    allow_any_instance_of(CasinoController).to receive(:winner).and_return("black")

    # Expect the spin button to be enabled and click it
    expect(page).to have_button('Spin')
    click_button 'Spin'

    # Wait for the result to appear
    expect(page).to have_css('#result', text: 'You lost!')

    # Check if the shard count has been updated correctly
    new_shards = initial_shards - 50  # Assuming the bet amount is lost
    expect(page).to have_content("Your Shards: #{new_shards}")
  end

  scenario 'User does not have enough shards to place a bet' do
    # Set a bet amount greater than the user's shard balance
    user.update(shards: 100)

    visit casino_path

    fill_in 'bet_amount', with: 200  # Bet more than they have
    find('.bet-button.red').click

    # Expect an alert message or error indicating insufficient shards
    click_button 'Spin'
    expect(page).to have_content('You don\'t have enough shards to place this bet.')
  end
end
