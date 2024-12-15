# spec/controllers/password_resets_controller_spec.rb
require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  let(:mock_user) { instance_double(User, id: 1, email: 'user@example.com', generate_reset_password_token!: true, reset_password_token: 'valid_token', reset_password_sent_at: Time.now.utc) }
  let(:invalid_user) { instance_double(User, email: 'invalid@example.com', reset_password_token: 'invalid_token', reset_password_sent_at: Time.now.utc - 2.hours) }
  let(:valid_attributes) { { password: 'newpassword', password_confirmation: 'newpassword' } }
  let(:invalid_attributes) { { password: 'short', password_confirmation: 'short' } }

  before do
    allow(User).to receive(:find_by).and_return(mock_user)
    allow(mock_user).to receive(:update).and_return(true)
  end

  describe 'GET #new' do
    it 'renders the new password reset form' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'when email is found' do
      it 'generates a reset token and sends an email' do
        expect(mock_user).to receive(:generate_reset_password_token!)
        expect(PasswordMailer).to receive_message_chain(:reset_password_email, :deliver)

        post :create, params: { email: 'user@example.com' }
        expect(flash[:email]).to eq('Email found')
      end
    end

    context 'when email is not found' do
      before do
        allow(User).to receive(:find_by).and_return(nil)
      end

      it 'does not generate a reset token' do
        post :create, params: { email: 'nonexistent@example.com' }
        expect(flash[:email]).to eq('Email not found')
      end
    end
  end

  describe 'GET #edit' do
    context 'when token is valid' do
      it 'renders the edit password form' do
        allow(mock_user).to receive(:reset_password_token_valid?).and_return(true)
        get :edit, params: { token: 'valid_token' }
        expect(response).to render_template(:edit)
      end
    end

    context 'when token is invalid' do
      it 'renders the edit page and shows an error flash message' do
        allow(mock_user).to receive(:reset_password_token_valid?).and_return(false)
        get :edit, params: { token: 'invalid_token' }
        expect(flash[:reseterr]).to eq('Reset password link is invalid or expired.')
        expect(response).to render_template(:edit) # No redirect to root_path
      end
    end
  end

  describe 'PATCH #update' do
    context 'when token is valid and update is successful' do
      it 'redirects to the login path' do
        allow(mock_user).to receive(:reset_password_token_valid?).and_return(true)
        allow(mock_user).to receive(:update).with(valid_attributes).and_return(true)

        patch :update, params: { id: 'valid_token', user: valid_attributes }
        expect(response).to redirect_to(login_path)
      end
    end

    context 'when token is invalid' do
      it 'shows an error flash message and redirects to login_path' do
        allow(mock_user).to receive(:reset_password_token_valid?).and_return(false)

        patch :update, params: { id: 'invalid_token', user: valid_attributes }
        expect(flash[:reseterr]).to eq('Reset password link is invalid or expired.')
        expect(response).to redirect_to(login_path) # No redirect to root_path, instead login_path
      end
    end
  end
end
