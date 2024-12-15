require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { create(:user, email: 'user@example.com', username: 'user123', password: 'password') }

  describe 'GET #new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid login credentials' do
      it 'logs the user in and redirects to games path' do
        post :create, params: { login: user.email, password: 'password' }

        expect(session[:user_id]).to eq(user.id)
        expect(flash[:notice]).to eq('Logged in successfully.')
        expect(response).to redirect_to(games_path)
      end
    end

    context 'with invalid login credentials' do
      it 'does not log the user in and re-renders the new template' do
        post :create, params: { login: user.email, password: 'wrongpassword' }

        expect(session[:user_id]).to be_nil
        expect(flash.now[:alert]).to eq('Invalid login credentials.')
        expect(response).to render_template(:new)
      end

      it 'fails when the username is incorrect' do
        post :create, params: { login: 'wrongusername', password: 'password' }

        expect(session[:user_id]).to be_nil
        expect(flash.now[:alert]).to eq('Invalid login credentials.')
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'logs the user out and redirects to the root path' do
      # Simulate logging in by setting the session directly
      session[:user_id] = user.id

      delete :destroy

      expect(session[:user_id]).to be_nil
      expect(flash[:notice]).to eq('Logged out successfully.')
      expect(response).to redirect_to(root_path)
    end
  end
end
