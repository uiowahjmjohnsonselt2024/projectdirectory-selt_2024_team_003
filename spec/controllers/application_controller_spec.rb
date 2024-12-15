# spec/controllers/application_controller_spec.rb
require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:mock_user) { instance_double(User, id: 1, credit_card: mock_credit_card, build_credit_card: mock_credit_card) }
  let(:mock_credit_card) { instance_double(CreditCard, save: true, destroy: true) }

  before do
    # Mocking the current_user method
    allow(controller).to receive(:current_user).and_return(mock_user)
  end

  describe 'authentication' do
    context 'when user is not logged in' do
      before do
        # Mock current_user to be nil
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it 'redirects to the login path' do
        # We expect that if the user is not logged in, the authenticate_user! method
        # will redirect the user to the login path
        expect(controller).to receive(:redirect_to).with(login_path)
        controller.authenticate_user!
      end
    end

    context 'when user is logged in' do
      it 'does not redirect to the login path' do
        # Ensure that authenticate_user! does not redirect if the user is logged in
        expect(controller).not_to receive(:redirect_to)
        controller.authenticate_user!
      end
    end
  end

  describe '#current_user' do
    context 'when there is a session with user_id' do
      before do
        # Mock session[:user_id] to simulate a logged-in user
        session[:user_id] = 1
        allow(User).to receive(:find_by).with(id: 1).and_return(mock_user)
      end

      it 'returns the correct user' do
        expect(controller.current_user).to eq(mock_user)
      end
    end

    context 'when there is no session with user_id' do
      before do
        session[:user_id] = nil
      end

      it 'returns nil' do
        expect(controller.current_user).to be_nil
      end
    end
  end

  describe '#logged_in?' do
    context 'when user is logged in' do
      before do
        allow(controller).to receive(:current_user).and_return(mock_user)
      end

      it 'returns true' do
        expect(controller.logged_in?).to be_truthy
      end
    end

    context 'when user is not logged in' do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it 'returns false' do
        expect(controller.logged_in?).to be_falsey
      end
    end
  end
end
