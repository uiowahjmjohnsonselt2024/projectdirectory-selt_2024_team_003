require 'rails_helper'

RSpec.describe "interactions/show.html.erb", type: :view do
  before do
    # Set up a mock current_user with a skin
    skin = create(:skin, archetype: "Attacker")
    user = skin.user
    user.update(current_skin: skin) # Associate the skin with the user as the current skin
    assign(:current_user, user)

    # Mock weapons
    assign(:weapons, [
      create(:weapon, name: 'Sword', current: true),
      create(:weapon, name: 'Bow and Arrow', current: false)
    ])

    # Mock consumables
    assign(:consumables, [
      create(:consumable, name: 'Health Potion', quantity: 2),
      create(:consumable, name: 'Mana Potion', quantity: 1)
    ])

    # Mock game_user with attributes
    assign(:game_user, create(:game_user, user: user, x_position: 1, y_position: 2, health: 80, mana: 50))

    # Mock enemy with full attributes
    assign(:enemy, create(:enemy, name: 'Goblin', health: 100, max_health: 100, level: 5, attack: 15, defense: 10, iq: 7))

    # Mock players in the same position
    assign(:players_in_same_pos, [
      create(:game_user, user: create(:user, username: 'Player2')),
      create(:game_user, user: create(:user, username: 'Player3'))
    ])

    # Mock game instance
    assign(:game, create(:game, code: 'GAME123'))
  end

  it "displays the player's avatar" do
    render
    expect(rendered).to have_css("img.player-avatar[src*='test_image.png']")
  end

  it "displays the player's stats" do
    render
    expect(rendered).to have_text("Your Stats")
    expect(rendered).to have_text("Your position: (1, 2)")
    expect(rendered).to have_text("Health: 80 /")
    expect(rendered).to have_text("Mana: 50 /")
  end

  it "renders health and mana progress bars" do
    render
    expect(rendered).to have_css("progress#player-health[value='80']")
    expect(rendered).to have_css("progress#player-mana[value='50']")
  end

  it "displays the inventory section with weapons and consumables" do
    render
    expect(rendered).to have_css(".inventory-section")
    expect(rendered).to have_css(".inventory-item.weapon-item", count: 2)
    expect(rendered).to have_text("Sword")
    expect(rendered).to have_text("Bow and Arrow")
    expect(rendered).to have_css(".inventory-item.consumable-item", count: 2)
    expect(rendered).to have_text("Health Potion")
    expect(rendered).to have_text("Mana Potion")
  end

  it "marks the current weapon with a green border" do
    render
    expect(rendered).to have_css(".current-weapon", text: "Sword")
  end

  it "displays the enemy details" do
    render
    expect(rendered).to have_css("img.enemy-avatar")
    expect(rendered).to have_text("Goblin")
    expect(rendered).to have_text("Level: 5")
    expect(rendered).to have_text("Health: 100")
    expect(rendered).to have_text("Attack: 15")
    expect(rendered).to have_text("Defense: 10")
    expect(rendered).to have_text("IQ: 7")
  end

  it "renders the enemy health progress bar" do
    render
    expect(rendered).to have_css("progress#enemy-health[value='100']")
  end

  it "displays the action buttons" do
    render
    expect(rendered).to have_button("Attack")
    expect(rendered).to have_button("Magic Attack")
    expect(rendered).to have_button("Magic Heal")
  end

  it "renders the action footer with the return link" do
    render
    expect(rendered).to have_link("Return to Grid", href: grid_path)
  end

  it "displays other players in the same position" do
    render
    expect(rendered).to have_css(".players-list")
    expect(rendered).to have_css(".player-card", count: 2)
    expect(rendered).to have_text("Player2")
    expect(rendered).to have_text("Player3")
  end

  it "renders player avatars for other players" do
    render
    expect(rendered).to have_css("img.profile-picture", count: 2)
  end

  it "renders consumable quantities" do
    render
    expect(rendered).to have_css(".item-quantity", text: "x2")
    expect(rendered).to have_css(".item-quantity", text: "x1")
  end

  it "renders the correct archetype for the current user" do
    render
    expect(rendered).to have_text("Attacker")
  end

  it "renders the game code for debugging purposes" do
    render
    expect(rendered).to have_text("GAME123")
  end

  it "displays proper CSS for current weapon highlighting" do
    render
    expect(rendered).to have_css(".current-weapon", text: "Sword")
  end
end
