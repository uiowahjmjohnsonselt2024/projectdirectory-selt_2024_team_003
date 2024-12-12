Feature: AI Sprite Generation
  As a player
  To make my character more personalized
  I want to generate an AI sprite for my character at the cost of shards

  Background:
    Given I am logged in as a player with a character
    And my character has 100 shards

  Scenario: Successfully generate an AI sprite
    When I visit the AI sprite generation page
    And I specify a description for my sprite as "A fierce dragon with flames"
    And I click on "Generate Sprite"
    Then I should see the "Generated AI Sprite" page
    And I should see the original AI-generated sprite
    And my shards balance should be reduced by 50
    And I should see the sprite saved to my character's profile

  Scenario: Not enough shards to generate a sprite
    Given my character has 10 shards
    When I visit the AI sprite generation page
    And I specify a description for my sprite as "A mystical phoenix"
    And I click on "Generate Sprite"
    Then I should see an error message "Not enough shards to generate a sprite"
    And my shards balance should remain 10
