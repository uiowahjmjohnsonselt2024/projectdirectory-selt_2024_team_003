# spec/controllers/sessions_controller_spec.rb

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { create(:user, email: "test@example.com", username: "testuser", password: "password") }

  describe "GET #new" do
    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "when login credentials are correct" do
      it "logs in with email and redirects to root path with a success notice" do
        post :create, params: { login: user.email, password: "password" }
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Logged in successfully.")
      end

      it "logs in with username and redirects to root path with a success notice" do
        post :create, params: { login: user.username, password: "password" }
        expect(session[:user_id]).to eq(user.id)
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Logged in successfully.")
      end
    end

    context "when login credentials are incorrect" do
      it "does not log in and renders new template with alert" do
        post :create, params: { login: user.email, password: "wrongpassword" }
        expect(session[:user_id]).to be_nil
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq("Invalid login credentials.")
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      session[:user_id] = user.id  # simulate user being logged in
    end

    it "logs out the user and redirects to root path with a success notice" do
      delete :destroy
      expect(session[:user_id]).to be_nil
      expect(response).to redirect_to(root_path)
      expect(flash[:notice]).to eq("Logged out successfully.")
    end
  end
end
