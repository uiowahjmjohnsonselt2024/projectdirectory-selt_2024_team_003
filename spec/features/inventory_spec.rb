require 'rails_helper'

RSpec.feature "Inventory", type: :feature do
  let(:user) { create(:user) }
  before do
    # Set up your test user and authenticate
    session[:user_id] = user.id

    # Create example inventory items
    create(:skin, user: user, archetype: 'Attacker')
    create(:weapon, user: user, name: 'Sword')
    create(:consumable, user: user, name: 'Health Potion', quantity: 5)

    visit inventory_index_path
  end


  scenario "User views the Inventory page" do
    expect(page).to have_content("Your Inventory")
    expect(page).to have_link("Avatars")
    expect(page).to have_link("Consumables")
    expect(page).to have_link("Weapons")
  end

  scenario "User views Avatars tab" do
    click_link "Avatars"
    expect(page).to have_content("Attacker") # Check for the skin archetype
    expect(page).to have_css(".skin-image")
    expect(page).to have_button("Equip")
    expect(page).to have_button("Remove")
  end

  scenario "User views Consumables tab" do
    click_link "Consumables"
    expect(page).to have_content("Health Potion")
    expect(page).to have_content("Quantity: 5")
    expect(page).to have_css(".consumable-image")
  end

  scenario "User views Weapons tab" do
    click_link "Weapons"
    expect(page).to have_content("Sword")
    expect(page).to have_css(".weapon-image")
    expect(page).to have_button("Equip")
  end

  scenario "User equips a skin" do
    click_link "Avatars"
    within(".skin-item") do
      click_button "Equip"
    end
    expect(page).to have_content("Currently Equipped")
  end

  scenario "User removes a skin" do
    click_link "Avatars"
    within(".skin-item") do
      click_button "Remove"
    end
    expect(page).not_to have_css(".skin-item")
  end

  scenario "User equips a weapon" do
    click_link "Weapons"
    within(".weapon-item") do
      click_button "Equip"
    end
    expect(page).to have_content("Currently Equipped")
  end

  scenario "User opens the skin stats modal" do
    click_link "Avatars"
    within(".skin-item") do
      click_on "showSkinStats"
    end
    expect(page).to have_css("#skin-stats-modal")
    expect(page).to have_content("Skin Stats")
  end

  scenario "User opens the weapon stats modal" do
    click_link "Weapons"
    within(".weapon-item") do
      click_on "showWeaponStats"
    end
    expect(page).to have_css("#weapon-stats-modal")
    expect(page).to have_content("Weapon Stats")
  end

  scenario "User opens the consumable stats modal" do
    click_link "Consumables"
    within(".consumable-item") do
      click_on "showConsumableStats"
    end
    expect(page).to have_css("#consumable-stats-modal")
    expect(page).to have_content("Consumable Details")
  end

  scenario "User sees a message when no consumables are present" do
    # Removing the consumable from the setup
    user = User.first
    user.consumables.destroy_all
    visit inventory_index_path(tab: 'consumables')
    expect(page).to have_content("You have no consumables.")
  end

  scenario "User sees a message when no weapons are present" do
    # Removing the weapon from the setup
    user = User.first
    user.weapons.destroy_all
    visit inventory_index_path(tab: 'weapons')
    expect(page).to have_content("You have no weapons.")
  end

  scenario "User sees a message when no skins are present" do
    # Removing the skin from the setup
    user = User.first
    user.skins.destroy_all
    visit inventory_index_path(tab: 'avatars')
    expect(page).to have_content("No image available")
  end
end
