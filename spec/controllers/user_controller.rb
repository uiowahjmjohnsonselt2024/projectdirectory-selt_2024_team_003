# spec/controllers/user_controller_spec.rb
require 'rails_helper'

RSpec.describe UserController, type: :controller do
  let(:user) { create(:user) }  # Assuming a user factory exists
  let(:friend) { create(:user) }  # A separate user for adding/removing friends
  let(:current_skin) { create(:skin, user: user) }  # Assuming you have a skin factory
  let(:friendship) { create(:friendship, user: user, friend: friend) }  # Assuming you have a friendship factory

  before do
    sign_in user
    allow(user).to receive(:current_skin).and_return(current_skin)
  end

  describe "GET #index" do
    it "assigns @image based on the current user's archetype" do
      allow(user).to receive(:archetype).and_return('Attacker')
      get :index
      expect(assigns(:image)).to eq('attack.png')
    end

    it "assigns @stats with current skin information" do
      get :index
      expect(assigns(:stats)).to include(
                                   { name: "Archetype", value: current_skin.archetype },
                                   { name: "Max Health", value: current_skin.health },
                                   { name: "Max Mana", value: current_skin.mana }
                                 )
    end

    it "assigns @users without the current user" do
      create(:user, username: "other_user")  # Create another user for searching
      get :index
      expect(assigns(:users).pluck(:username)).to include("other_user")
      expect(assigns(:users).pluck(:username)).not_to include(user.username)
    end

    it "filters users by search when params[:search] is provided" do
      create(:user, username: "searched_user")  # User to be searched
      get :index, params: { search: "searched" }
      expect(assigns(:users).pluck(:username)).to include("searched_user")
    end
  end

  describe "POST #add_friend" do
    context "when the friend is not already in the friends list" do
      it "creates a friendship and adds the user to the friends list" do
        post :add_friend, params: { friend_id: friend.id }
        expect(flash[:notice]).to eq("#{friend.username} has been added to your friends list!")
        expect(current_user.friends).to include(friend)
        expect(response).to redirect_to(account_path)
      end
    end

    context "when the friend is already in the friends list" do
      before { current_user.friendships.create(friend: friend) }

      it "does not create a new friendship and shows an alert" do
        post :add_friend, params: { friend_id: friend.id }
        expect(flash[:alert]).to eq("#{friend.username} is already your friend.")
        expect(response).to redirect_to(account_path)
      end
    end
  end

  describe "POST #remove_friend" do
    context "when the friend is in the friends list" do
      before { friendship }

      it "removes the friend from the friends list" do
        post :remove_friend, params: { friend_id: friend.id }
        expect(flash[:notice]).to eq("#{friend.username} has been removed from your friends list.")
        expect(current_user.friends).not_to include(friend)
        expect(response).to redirect_to(account_path)
      end
    end

    context "when the friend is not in the friends list" do
      it "shows an alert and does not remove the friend" do
        post :remove_friend, params: { friend_id: friend.id }
        expect(flash[:alert]).to eq("#{friend.username} is not your friend.")
        expect(response).to redirect_to(account_path)
      end
    end
  end

  describe "GET #edit" do
    it "renders the edit template" do
      get :edit, params: { id: user.id }
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH #update" do
    context "when the update is successful" do
      it "updates the user's profile and redirects to the account page" do
        patch :update, params: { id: user.id, user: { profile_picture: 'new_picture.jpg' } }
        expect(user.reload.profile_picture).to eq('new_picture.jpg')
        expect(flash[:notice]).to eq('Profile updated successfully.')
        expect(response).to redirect_to(account_path)
      end
    end

    context "when the update fails" do
      it "does not update the user's profile and renders the edit page" do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        patch :update, params: { id: user.id, user: { profile_picture: 'invalid_picture' } }
        expect(flash[:alert]).to eq('Failed to update profile.')
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "private methods" do
    describe "#set_user" do
      it "assigns @user" do
        get :edit, params: { id: user.id }
        expect(assigns(:user)).to eq(user)
      end
    end

    describe "#user_params" do
      it "permits the :profile_picture parameter" do
        params = { user: { profile_picture: 'profile_pic.jpg' } }
        result = controller.send(:user_params)
        expect(result[:profile_picture]).to eq('profile_pic.jpg')
      end
    end
  end
end
