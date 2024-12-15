require 'rails_helper'

RSpec.feature "InteractionPage", type: :feature do
  let!(:game) { create(:game) }
  let!(:user) { create(:user) }
  let!(:weapon) { create(:weapon, game: game, user: user) }
  let!(:consumable) { create(:consumable, game: game, user: user, quantity: 3) }

  before do
    # Log in the user if authentication is required
    session[:user_id] = user

    # Visit the interaction page for the given game
    visit interaction_path(game)
  end

  scenario "User can see and interact with their weapons" do
    # Verify the player's weapon is displayed
    expect(page).to have_content(weapon.name)
    expect(page).to have_css(".weapon-item", text: weapon.name)

    # Click to use the weapon
    find(".weapon-item", text: weapon.name).click

    # Verify that the weapon is selected (add 'current-weapon' class)
    expect(page).to have_css(".weapon-item.current-weapon", text: weapon.name)
  end

  scenario "User can see and interact with consumables" do
    # Verify consumable item is displayed
    expect(page).to have_content(consumable.name)
    expect(page).to have_content("x3")  # Initial quantity of consumable

    # Click on consumable item to use it
    find(".consumable-item", text: consumable.name).click

    # Verify quantity is updated
    expect(page).to have_content("x2")  # Quantity should decrease by 1
  end

  scenario "User's stats are displayed correctly" do
    # Verify the user's health, mana, and other stats are displayed
    expect(page).to have_content("Health:")
    expect(page).to have_content("Mana:")

    # Verify player stats are updated on the page
    within("#player-1-health") do
      expect(page).to have_text("#{game.user.health} / #{game.user.max_health}")
    end
    within("#player-1-mana") do
      expect(page).to have_text("#{game.user.mana} / #{game.user.max_mana}")
    end
  end

  scenario "User can join the game" do
    # Check if the "Join Game" button is visible
    expect(page).to have_button("Join Game")

    # Click the button to join the game
    click_button "Join Game"

    # Verify that the button is no longer visible after joining
    expect(page).to have_no_button("Join Game")
  end

  scenario "User can attack in the game" do
    # Verify attack button is present
    expect(page).to have_button("Attack")

    # Click the attack button
    click_button "Attack"

    # Verify that an attack message is displayed in the message container
    expect(page).to have_css("#attack-message p", text: "Attack performed successfully!")
  end

  scenario "User can use special attack in the game" do
    # Verify magic attack button is present
    expect(page).to have_button("Magic Attack")

    # Click the magic attack button
    click_button "Magic Attack"

    # Verify that a special attack message is displayed in the message container
    expect(page).to have_css("#attack-message p", text: "Magic Attack performed successfully!")
  end
end
