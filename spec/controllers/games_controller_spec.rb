require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:game_with_code) { create(:game, code: 'ABC123') }

  before do
    sign_in user
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET #index" do
    it "assigns @games to all games of the current user" do
      user_games = create_list(:game, 3, user: user)
      get :index
      expect(assigns(:games)).to match_array(user_games)
    end
  end

  describe "POST #create" do
    context "when the game is successfully created" do
      let(:valid_game_params) { { game: { name: 'New Game' } } }

      it "creates a new game and associates it with the current user" do
        expect {
          post :create, params: valid_game_params
        }.to change(Game, :count).by(1).and change(GameUser, :count).by(1)
      end

      it "redirects to the grid page" do
        post :create, params: valid_game_params
        expect(response).to redirect_to(grid_path)
      end

      it "sets the game code in session" do
        post :create, params: valid_game_params
        expect(session[:game_code]).to be_present
      end
    end

    context "when the game creation fails" do
      let(:invalid_game_params) { { game: { name: '' } } }

      it "does not create a new game" do
        expect {
          post :create, params: invalid_game_params
        }.not_to change(Game, :count)
      end

      it "redirects back to the games page with a flash alert" do
        post :create, params: invalid_game_params
        expect(flash[:alert]).to eq('Failed to create game')
        expect(response).to redirect_to(games_path)
      end
    end
  end

  describe "POST #join" do
    context "when the game exists" do
      context "and the user is not already in the game" do
        it "creates a new GameUser and redirects to the grid page" do
          expect {
            post :join, params: { code: game_with_code.code }
          }.to change(GameUser, :count).by(1)
          expect(response).to redirect_to(grid_path)
        end
      end

      context "and the user has already joined the game" do
        before do
          GameUser.create(user: user, game: game_with_code)
        end

        it "redirects to the grid page without creating a new GameUser" do
          expect {
            post :join, params: { code: game_with_code.code }
          }.not_to change(GameUser, :count)
          expect(response).to redirect_to(grid_path)
        end
      end
    end

    context "when the game does not exist" do
      it "sets a flash alert and redirects to the games page" do
        post :join, params: { code: 'INVALIDCODE' }
        expect(flash[:alert]).to eq("The game with code INVALIDCODE does not exist.")
        expect(response).to redirect_to(games_path)
      end
    end
  end

  describe "GET #win" do
    it "assigns @game and @game_code based on the given game_id" do
      get :win, params: { game_id: game_with_code.code }
      expect(assigns(:game)).to eq(game_with_code)
      expect(assigns(:game_code)).to eq(game_with_code.code)
    end
  end

  describe "DELETE #end" do
    it "destroys the game and redirects to the games page with a notice" do
      game_to_end = create(:game, code: 'ENDGAME')
      delete :end, params: { game_code: game_to_end.code }
      expect(Game.exists?(game_to_end.id)).to be_falsey
      expect(flash[:notice]).to eq('Game has ended. Thank you for playing!')
      expect(response).to redirect_to(games_path)
    end
  end
end
