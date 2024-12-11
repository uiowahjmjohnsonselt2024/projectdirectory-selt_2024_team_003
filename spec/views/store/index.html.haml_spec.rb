require 'rails_helper'

RSpec.describe "store/index.html.haml", type: :view do
  before do
    # Assuming you have models for each item type like Shards, Avatars, etc.
    # You can create some test data to verify if items are displayed correctly.
    assign(:shards, [
      { name: "100 Shards", price: 0.99, description: "A small shard, perfect for minor upgrades.", image: "gem1.gif" },
      { name: "500 Shards", price: 3.00, description: "A medium-sized shard, useful for moderate upgrades.", image: "gem2.gif" },
      { name: "2500 Shards", price: 14.99, description: "A large shard, ideal for powerful upgrades.", image: "gem3.gif" }
    ])
    assign(:avatars, [
      { name: "Avatar 1", price: 300, description: "A warrior avatar with enhanced strength.", image: "avatar_1.jpg" },
      { name: "Avatar 2", price: 450, description: "A mage avatar with powerful spells.", image: "avatar_2.jpg" }
    ])
    assign(:consumables, [
      { name: "Health Potion", price: 100, description: "Restores health over time.", image: "healthPotion.gif" },
      { name: "Acid Potion", price: 150, description: "Deals damage to enemies upon contact.", image: "acidPotion.gif" },
      { name: "Revive", price: 150, description: "Revives a fallen ally.", image: "revive.gif" }
    ])
    # Add similar assigns for other categories if necessary.
  end

  it "renders the Shards section with items" do
    render

    expect(rendered).to have_css('.item-list#shards-list')  # Check if shards list is present
    expect(rendered).to have_content("100 Shards")         # Check for an item title
    expect(rendered).to have_content("$0.99")              # Check for an item price
    expect(rendered).to have_content("A small shard, perfect for minor upgrades.")  # Check for item description
  end

  it "renders the Avatars section with items" do
    render

    expect(rendered).to have_css('.item-list#avatars-list')  # Check if avatars list is present
    expect(rendered).to have_content("Avatar 1")             # Check for avatar name
    expect(rendered).to have_content("300 Shards")           # Check for price in shards
    expect(rendered).to have_content("A warrior avatar with enhanced strength.")  # Check for description
  end

  it "renders the Consumables section with items" do
    render

    expect(rendered).to have_css('.item-list#consumables-list')  # Check if consumables list is present
    expect(rendered).to have_content("Health Potion")            # Check for item title
    expect(rendered).to have_content("$0.99")                    # Check for item price
    expect(rendered).to have_content("Restores health over time.")  # Check for description
  end

  it "checks that initially Shards category is visible" do
    render

    expect(rendered).to have_css('.item-list#shards-list', visible: true)  # Shards list should be visible by default
    expect(rendered).to have_css('.item-list#avatars-list', visible: false) # Other categories should not be visible
  end

  it "checks that clicking a tab hides other categories and shows the correct one" do
    render

    # Simulate clicking the "Avatars" tab
    execute_script('showCategory("avatars")')

    expect(rendered).to have_css('.item-list#shards-list', visible: false)  # Shards list should be hidden
    expect(rendered).to have_css('.item-list#avatars-list', visible: true)   # Avatars list should be visible
  end

  it "has the correct background image" do
    render

    expect(rendered).to have_css(".background-img", visible: true)  # Ensure background is present
    expect(rendered).to match(/shopBackground.jfif/)  # Check the background image is set correctly
  end

  it "checks if the header contains Shards count" do
    render

    expect(rendered).to have_content("Shards: 1000")  # Make sure the header displays the shards correctly
  end

  it "ensures the Purchase buttons are present" do
    render

    expect(rendered).to have_button('Purchase')  # Ensure purchase button is rendered for each item
  end
end
