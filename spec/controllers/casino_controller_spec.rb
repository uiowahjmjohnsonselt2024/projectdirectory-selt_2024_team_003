require 'rails_helper'

RSpec.describe CasinoController, type: :controller do
  let(:user) { create(:user, shards: 100) }  # Assuming you have a factory for User
  let(:game) { create(:game) }  # Assuming you have a factory for Game

  before do
    sign_in user  # Assuming you're using Devise or similar
    session[:game_code] = game.code
  end

  describe "POST #place_bet" do
    let(:valid_params) { { bet_amount: 50, user_bet: 'red', winner: 'red' } }
    let(:invalid_params) { { bet_amount: 150, user_bet: 'red', winner: 'red' } }

    context "when user has enough shards" do
      it "deducts the bet amount and updates the shard balance after a win" do
        post :place_bet, params: valid_params
        user.reload
        expect(user.shards).to eq(150)  # User wins and gets double the bet amount
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_truthy
        expect(json_response['result']).to match(/You won! \d+ shards./)
      end

      it "deducts the bet amount and updates the shard balance after a loss" do
        post :place_bet, params: { bet_amount: 50, user_bet: 'red', winner: 'black' }
        user.reload
        expect(user.shards).to eq(50)  # User loses the bet amount
        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_truthy
        expect(json_response['result']).to match(/You lost! The spin landed on black./)
      end
    end

    context "when user does not have enough shards" do
      it "does not allow the bet and returns an error" do
        user.update(shards: 10)  # User has less than the required bet amount
        post :place_bet, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_falsey
        expect(json_response['message']).to eq('Insufficient shards or invalid bet amount.')
      end
    end

    context "when the bet amount is invalid" do
      it "returns an error" do
        post :place_bet, params: { bet_amount: -10, user_bet: 'red', winner: 'red' }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be_falsey
        expect(json_response['message']).to eq('Insufficient shards or invalid bet amount.')
      end
    end
  end
end
