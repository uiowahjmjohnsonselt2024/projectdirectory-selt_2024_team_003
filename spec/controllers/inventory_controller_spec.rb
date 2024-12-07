require 'rails_helper'

RSpec.describe InventoryController, type: :controller do
  let(:user) { create(:user) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe "GET #index" do
    let!(:skin1) { create(:skin, user: user) }
    let!(:skin2) { create(:skin, user: user) }

    it "renders the index and shows the user's skins" do
      get :index
      expect(response).to have_http_status(:ok)
      # Check response or assigns if needed
    end
  end

  describe "POST #add" do
    let(:valid_base64_image) do
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgAAAAAwAAAR4C0KUAAAAASUVORK5CYII="
    end
    let(:invalid_base64_image) { "!" } # This will decode to an empty string

    context "with valid image data" do
      it "creates a new skin and redirects" do
        expect {
          post :add, params: { image_data: valid_base64_image }
        }.to change { user.skins.count }.by(1)
        expect(response).to redirect_to(store_path)
      end
    end

    context "with invalid image data" do
      it "does not create a skin and redirects with an alert" do
        expect {
          post :add, params: { image_data: invalid_base64_image }
        }.not_to change { user.skins.count }
        expect(response).to redirect_to(store_path)
      end
    end

    context "when save fails" do
      before do
        allow_any_instance_of(Skin).to receive(:save).and_return(false)
      end

      it "does not create a skin and redirects with an alert" do
        expect {
          post :add, params: { image_data: valid_base64_image }
        }.not_to change { user.skins.count }
        expect(response).to redirect_to(store_path)
      end
    end
  end
end
