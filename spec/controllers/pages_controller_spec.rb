# spec/controllers/pages_controller_spec.rb
require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  let(:user) { create(:user) } # Assuming you have a factory for user
  let(:game) { create(:game) } # Assuming you have a factory for game
  let(:game_user) { create(:game_user, game: game, user: user) } # Factory for game_user
  let(:current_skin) { create(:skin, user: user) }

  before do
    sign_in user
    session[:game_code] = game.code
    allow(user).to receive(:current_skin).and_return(current_skin)
  end

  describe "GET #grid" do
    it "assigns @user_name" do
      get :grid, params: { game_code: game.code }
      expect(assigns(:user_name)).to eq(user.username)
    end

    it "assigns @players excluding current user" do
      create(:game_user, game: game, user: create(:user)) # Create another player in the game
      get :grid, params: { game_code: game.code }
      expect(assigns(:players).pluck(:username)).not_to include(user.username)
    end

    it "assigns @stats from current skin" do
      get :grid, params: { game_code: game.code }
      expect(assigns(:stats)).to include(
                                   { name: "Archetype", value: current_skin.archetype },
                                   { name: "Attack", value: current_skin.attack }
                                 )
    end

    it "assigns @adjacent_tiles based on current position" do
      allow(controller).to receive(:calculate_adjacent_tiles).and_return([{ x: 0, y: 0 }])
      get :grid, params: { game_code: game.code }
      expect(assigns(:adjacent_tiles)).to eq([{ x: 0, y: 0 }])
    end

    it "stores current position in session" do
      get :grid, params: { game_code: game.code }
      expect(session[:current_position]).not_to be_nil
    end

    it "redirects to grid with new position when x and y params are present" do
      get :grid, params: { game_code: game.code, x: 3, y: 4 }
      expect(response).to redirect_to(grid_path(x: 3, y: 4))
    end
  end

  describe "GET #back_to_grid" do
    context "when current position is stored in session" do
      before { session[:current_position] = { x: 5, y: 6 } }

      it "redirects to grid with stored position" do
        get :back_to_grid
        expect(response).to redirect_to(grid_path(x: 5, y: 6))
      end
    end

    context "when current position is not stored in session" do
      it "redirects with an alert message" do
        get :back_to_grid
        expect(response).to redirect_to(grid_path)
        expect(flash[:alert]).to eq('Unable to return to your previous position.')
      end
    end
  end

  describe "POST #move" do
    context "when move is valid" do
      before do
        allow(game_user).to receive(:move_to).and_return(true)
      end

      it "returns success message and new position" do
        post :move, params: { x_position: 2, y_position: 3 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq('Move successful')
      end
    end

    context "when move is invalid" do
      before do
        allow(game_user).to receive(:move_to).and_return(false)
      end

      it "returns error message" do
        post :move, params: { x_position: 2, y_position: 3 }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq("You can't move to this square")
      end
    end
  end

  describe "POST #check_shards" do
    context "when user has enough shards" do
      before { allow(user).to receive(:shards).and_return(20) }

      it "returns success message" do
        post :check_shards, params: { cost: 10 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["success"]).to eq(true)
      end
    end

    context "when user has insufficient shards" do
      before { allow(user).to receive(:shards).and_return(5) }

      it "returns error message" do
        post :check_shards, params: { cost: 10 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["success"]).to eq(false)
        expect(JSON.parse(response.body)["message"]).to eq('Insufficient shards')
      end
    end
  end

  describe "POST #force_move" do
    context "when user has enough shards" do
      before { allow(user).to receive(:shards).and_return(20) }

      it "returns success message and new position" do
        post :force_move, params: { x_position: 3, y_position: 4 }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq('Force move successful')
      end
    end

    context "when user has insufficient shards" do
      before { allow(user).to receive(:shards).and_return(5) }

      it "returns error message" do
        post :force_move, params: { x_position: 3, y_position: 4 }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to eq('Insufficient shards')
      end
    end
  end

  describe "private methods" do
    describe "#set_game_user" do
      it "assigns @game_user" do
        get :grid, params: { game_code: game.code }
        expect(assigns(:game_user)).to eq(game_user)
      end

      it "renders json with error if player is not found in game" do
        allow(user).to receive(:game_users).and_return([])
        get :grid, params: { game_code: game.code }
        expect(response.body).to include("Player not found in this game")
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "#calculate_adjacent_tiles" do
      it "returns valid adjacent tiles" do
        result = controller.send(:calculate_adjacent_tiles, 1, 1)
        expect(result).to include({ x: 1, y: 1 }, { x: 0, y: 1 }, { x: 2, y: 1 })
      end

      it "excludes invalid grid coordinates" do
        result = controller.send(:calculate_adjacent_tiles, -1, -1)
        expect(result).not_to include({ x: -1, y: -1 })
      end
    end
  end
end
