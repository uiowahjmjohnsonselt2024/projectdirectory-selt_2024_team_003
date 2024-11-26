require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns @welcome_message" do
      get :index
      expect(assigns(:welcome_message)).to eq("Welcome to Shards of the Grid!")
    end

    it "assigns @login_button" do
      get :index
      expect(assigns(:login_button)).to eq("Login")
    end

    it "assigns @create_button" do
      get :index
      expect(assigns(:create_button)).to eq("Create")
    end

    it "assigns @copyright_text" do
      get :index
      expect(assigns(:copyright_text)).to eq("&copy; 2024 Shards of the Grid. All rights reserved.")
    end
  end
end
rved.")
    end
  end
end
