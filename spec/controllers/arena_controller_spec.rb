require 'rails_helper'

RSpec.describe ArenaController, type: :controller do
  let(:game) { create(:game) }
  let(:user) { create(:user) }
  let(:game_user) { create(:game_user, game: game, user: user) }
  let(:enemy) { create(:enemy, game: game, x_position: game_user.x_position, y_position: game_user.y_position) }
  let(:weapon) { create(:weapon, user: user) }
  let(:consumable) { create(:consumable, user: user) }
  let(:skin) { create(:skin, user: user) }

  before do
    sign_in user
    allow(controller).to receive(:current_user).and_return(user)
    allow(user).to receive(:current_skin).and_return(skin)
    allow(user).to receive(:weapons).and_return([weapon])
    allow(user).to receive(:consumables).and_return([consumable])
  end

  describe "GET #index" do
    context "when the game and game_user are found" do
      before do
        game.update(code: "123ABC") # Set the game code
        get :index, params: { game_id: game.code }
      end

      it "assigns @game correctly" do
        expect(assigns(:game)).to eq(game)
      end

      it "assigns @game_user correctly" do
        expect(assigns(:game_user)).to eq(game_user)
      end

      it "assigns @enemy based on x_position and y_position" do
        expect(assigns(:enemy)).to eq(enemy)
      end

      it "assigns @player as current_skin" do
        expect(assigns(:player)).to eq(skin)
      end

      it "assigns @weapons correctly" do
        expect(assigns(:weapons)).to eq([weapon])
      end

      it "assigns @consumables correctly" do
        expect(assigns(:consumables)).to eq([consumable])
      end

      it "assigns @user correctly" do
        expect(assigns(:user)).to eq(user)
      end
    end

    context "when the player's archetype is 'Attacker'" do
      before do
        allow(skin).to receive(:archetype).and_return('Attacker')
        get :index, params: { game_id: game.code }
      end

      it "assigns @image as 'attack.png'" do
        expect(assigns(:image)).to eq('attack.png')
      end
    end

    context "when the player's archetype is 'Defender'" do
      before do
        allow(skin).to receive(:archetype).and_return('Defender')
        get :index, params: { game_id: game.code }
      end

      it "assigns @image as 'defense.png'" do
        expect(assigns(:image)).to eq('defense.png')
      end
    end

    context "when the player's archetype is 'Healer'" do
      before do
        allow(skin).to receive(:archetype).and_return('Healer')
        get :index, params: { game_id: game.code }
      end

      it "assigns @image as 'balanced.png'" do
        expect(assigns(:image)).to eq('balanced.png')
      end
    end

    context "when the player's archetype is unknown" do
      before do
        allow(skin).to receive(:archetype).and_return(nil)
        get :index, params: { game_id: game.code }
      end

      it "assigns @image as 'balanced.png'" do
        expect(assigns(:image)).to eq('balanced.png')
      end
    end
  end
end
