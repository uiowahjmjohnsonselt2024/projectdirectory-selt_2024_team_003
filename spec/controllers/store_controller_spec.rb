require 'rails_helper'

RSpec.describe StoreController, type: :controller do
  let(:user) { create(:user, shards: 100) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "POST #purchase_shards" do
    context "when purchasing shards successfully" do
      it "adds shards to the user's account" do
        post :purchase_shards, params: { shard_count: 50 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["success"]).to be_truthy
        expect(json["shards"]).to eq(user.shards)
      end
    end

    context "when shard update fails" do
      before do
        allow(user).to receive(:save).and_return(false)
      end

      it "returns an error message" do
        post :purchase_shards, params: { shard_count: 50 }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["success"]).to be_falsey
        expect(json["message"]).to eq("Failed to update shards.")
      end
    end
  end

  describe "POST #purchase_item" do
    context "when user has enough shards" do
      it "deducts shards and confirms purchase" do
        post :purchase_item, params: { itemType: "Sword", itemPrice: 50 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["success"]).to be_truthy
        expect(json["message"]).to eq("Sword purchased successfully!")
        expect(json["shards"]).to eq(50) # 100 - 50 = 50
      end
    end

    context "when user does not have enough shards" do
      it "returns an insufficient funds error" do
        post :purchase_item, params: { itemType: "Sword", itemPrice: 150 }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["success"]).to be_falsey
        expect(json["message"]).to eq("Insufficient funds for Sword.")
      end
    end
  end
end
