Given("I am logged in as a player with a character") do
  @player = create(:player) # Creates a player using FactoryBot
  @character = create(:character, player: @player, shards: 100) # Links the character to the player
  login_as(@player, scope: :player) # Logs in the player (Devise or equivalent)
end

Given("my character has {int} shards") do |shards|
  @character.update!(shards: shards) # Updates the character's shard balance
end

When("I visit the AI sprite generation page") do
  visit '/ai_sprites/generate' # Navigates to the AI sprite generation page
end

When("I specify a description for my sprite as {string}") do |description|
  fill_in "Description", with: description # Fills in the description field
end

When("I click on {string}") do |button_text|
  click_button button_text # Clicks the button with the given text
end

Then("I should see the {string} page") do |title|
  expect(page).to have_content(title) # Verifies the page has the given title
end

Then("I should see the original AI-generated sprite") do
  expect(page).to have_selector("img[src*='http']") # Checks for an image with a URL source
end

Then("my shards balance should be reduced by {int}") do |shards_spent|
  remaining_shards = @character.reload.shards # Reloads the character to get the updated shard balance
  expect(remaining_shards).to eq(100 - shards_spent) # Verifies the shards were deducted correctly
end

Then("my shards balance should remain {int}") do |shards|
  expect(@character.reload.shards).to eq(shards) # Verifies the shards balance remains unchanged
end

Then("I should see the sprite saved to my character's profile") do
  expect(@character.reload.sprite_url).not_to be_nil # Checks that the sprite URL is saved to the character
end

Then("I should see an error message {string}") do |error_message|
  expect(page).to have_content(error_message) # Verifies the error message is displayed
end
