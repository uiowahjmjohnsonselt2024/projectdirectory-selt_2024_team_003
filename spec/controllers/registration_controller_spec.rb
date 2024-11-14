# spec/controllers/registrations_controller_spec.rb

require 'rails_helper'

describe RegistrationsController, type: :controller do
  describe "GET #new" do
    it "assigns a new User to @user" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end

    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "when the user details are valid" do
      let(:valid_params) do
        {
          user: {
            username: "testuser",
            email: "test@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
      end

      it "creates a new user and saves to the database" do
        expect {
          post :create, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "logs in the new user by setting session[:user_id]" do
        post :create, params: valid_params
        expect(session[:user_id]).to eq(User.last.id)
      end

      it "redirects to the root path with a success notice" do
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Account created successfully.")
      end
    end

    context "when the user details are invalid" do
      let(:invalid_params) do
        {
          user: {
            username: "",
            email: "invalidemail",
            password: "password",
            password_confirmation: "different_password"
          }
        }
      end

      it "does not create a new user in the database" do
        expect {
          post :create, params: invalid_params
        }.not_to change(User, :count)
      end

      it "renders the new template with an alert" do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(flash.now[:alert]).to eq("Invalid")
      end
    end
  end
end
