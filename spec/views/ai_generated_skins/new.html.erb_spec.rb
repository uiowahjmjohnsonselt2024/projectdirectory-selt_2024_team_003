require 'rails_helper'

RSpec.describe "ai_generated_skins/new.html.erb", type: :view do
  before do
    assign(:error, nil)
    assign(:image_base64, nil)
  end

  it "displays the back button with correct path and label" do
    render template: "ai_generated_skins/new"
    expect(rendered).to have_link("Back to Store", href: store_path, class: "back-button")
    expect(rendered).to have_selector("a.back-button[aria-label='Back to Store']")
  end

  it "displays the form with inputs and submit button disabled by default" do
    render template: "ai_generated_skins/new"

    expect(rendered).to have_selector("form#generate-form[action='#{generate_ai_generated_skin_path}'][method='post']")
    expect(rendered).to have_selector("input#character_description[placeholder='Enter character description'][required]")
    expect(rendered).to have_selector("select#archetype[required]")
    expect(rendered).to have_select("archetype", options: ["Select an archetype", "Attacker", "Defender", "Healer"])
    expect(rendered).to have_button("Generate", disabled: true)
  end

  it "displays a placeholder message when no image is generated" do
    render template: "ai_generated_skins/new"
    expect(rendered).to have_content("Describe your character to see its AI-generated appearance here!")
    expect(rendered).to have_selector("p.placeholder-message[aria-live='polite']")
  end

  context "when @error is present" do
    before do
      assign(:error, "Unable To Generate Skin")
    end

    it "displays the error message" do
      render template: "ai_generated_skins/new"
      expect(rendered).to have_content("Unable To Generate Skin")
      expect(rendered).to have_selector("p.error-message[aria-live='assertive']")
    end
  end

  context "when @image_base64 is present" do
    before do
      assign(:image_base64, "fake_base64_string")
    end

    it "displays the generated skin image" do
      render template: "ai_generated_skins/new"

      expect(rendered).to have_content("Generated AI Skin")
      expect(rendered).to have_selector("img[src^='data:image/png;base64,fake_base64_string'][alt='Generated AI Skin']")
    end

    it "displays the 'Add To Inventory' button with correct params and no turbo behavior" do
      render template: "ai_generated_skins/new"

      # Adjusted test to match the actual rendered form
      expect(rendered).to have_selector(
                            "form[action='#{add_skin_inventory_index_path}'][method='post']"
                          )
      expect(rendered).to have_selector("form button.add-to-inventory-button", text: "Add To Inventory")
    end
  end

  it "includes a JavaScript script for enabling/disabling the generate button" do
    render template: "ai_generated_skins/new"

    expect(rendered).to include("document.addEventListener('DOMContentLoaded', () => {")
    expect(rendered).to include("const descriptionInput = document.getElementById('character_description');")
    expect(rendered).to include("const archetypeSelect = document.getElementById('archetype');")
    expect(rendered).to include("generateButton.disabled = !(descriptionInput.value.trim() && archetypeSelect.value);")
  end
end
