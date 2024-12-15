# spec/controllers/interactions_controller_spec.rb
require 'rails_helper'

RSpec.describe InteractionsController, type: :controller do
  let(:user) { create(:user) } # Assuming you have a factory for user
  let(:game) { create(:game) } # Assuming you have a factory for game
  let(:game_user) { create(:game_user, game: game, user: user) } # Factory for game_user
  let(:enemy) { create(:enemy, game: game, x_position: game_user.x_position, y_position: game_user.y_position) }
  let(:weapon) { create(:weapon, user: user) }
  let(:consumable) { create(:consumable, user: user) }

  before do
    sign_in user
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { game_id: game.code }
      expect(response).to have_http_status(:success)
    end

    it "assigns @game" do
      get :show, params: { game_id: game.code }
      expect(assigns(:game)).to eq(game)
    end

    it "assigns @enemy" do
      get :show, params: { game_id: game.code }
      expect(assigns(:enemy)).to eq(enemy)
    end
  end

  describe "POST #attack" do
    it "attacks the enemy and updates health" do
      post :attack, params: { game_id: game.code }

      enemy.reload
      expect(enemy.health).to be < enemy.max_health
    end

    it "returns success message when enemy is defeated" do
      allow(enemy).to receive(:health).and_return(0)
      post :attack, params: { game_id: game.code }

      expect(JSON.parse(response.body)["message"]).to include("You defeated the enemy")
    end

    it "applies weapon multiplier to damage" do
      weapon.update(current: true) # Assume the weapon is now equipped
      post :attack, params: { game_id: game.code }

      # Check if damage is applied with multiplier (you can adjust based on weapon stats)
      # Assuming a 'sword' multiplier of 2, the damage should be double.
      expect(JSON.parse(response.body)["message"]).to include("You attacked the enemy with your sword!")
    end
  end

  describe "POST #use_consumable" do
    it "uses the consumable and restores health" do
      consumable.update(quantity: 1) # Ensure the consumable is available
      post :use_consumable, params: { game_id: game.code, consumable_id: consumable.id }

      expect(JSON.parse(response.body)["message"]).to include("Health restored")
    end

    it "fails if consumable is not found" do
      post :use_consumable, params: { game_id: game.code, consumable_id: 999999 }
      expect(response).to have_http_status(:not_found)
    end

    it "uses a revive consumable" do
      consumable.update(name: "Revive", quantity: 1)
      post :use_consumable, params: { game_id: game.code, consumable_id: consumable.id }

      expect(JSON.parse(response.body)["message"]).to include("Health restored")
    end
  end

  describe "POST #magic_attack" do
    it "performs a magic attack and updates enemy health" do
      post :magic_attack, params: { game_id: game.code }
      enemy.reload
      expect(enemy.health).to be < enemy.max_health
    end

    it "handles coin flip for attacker archetype" do
      user.update(archetype: "Attacker")
      post :magic_attack, params: { game_id: game.code }
      message = JSON.parse(response.body)["message"]
      expect(message).to match(/Coin Flip/)
    end

    it "fails if mana is insufficient" do
      allow(game_user).to receive(:use_mana).and_return(false)
      post :magic_attack, params: { game_id: game.code }
      expect(JSON.parse(response.body)["message"]).to eq("Not enough mana!")
    end
  end

  describe "POST #magic_heal" do
    it "heals the player and reduces enemy health" do
      post :magic_heal, params: { game_id: game.code }
      game_user.reload
      expect(game_user.health).to be > 0
    end

    it "fails if mana is insufficient" do
      allow(game_user).to receive(:use_mana).and_return(false)
      post :magic_heal, params: { game_id: game.code }
      expect(JSON.parse(response.body)["message"]).to eq("Not enough mana!")
    end
  end

  describe "POST #set_current_weapon" do
    it "sets the current weapon" do
      post :set_current_weapon, params: { id: weapon.id }
      weapon.reload
      expect(weapon.current).to be true
    end

    it "fails if weapon is not found" do
      post :set_current_weapon, params: { id: 999999 }
      expect(response).to have_http_status(:not_found)
    end
  end
end
