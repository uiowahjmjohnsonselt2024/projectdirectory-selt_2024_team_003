require 'rails_helper'

RSpec.describe SelectionsController, type: :controller do
  let(:mock_image) { instance_double(ActiveStorage::Attached::One, attach: true) }
  let(:mock_skin) { instance_double(Skin, save: true, errors: double(full_messages: ['Error saving skin'])) }
  let(:mock_weapon) { instance_double(Weapon, save: true, errors: double(full_messages: ['Error saving weapon'])) }
  let(:mock_user) { instance_double(User, id: 1, skins: double('skins', build: mock_skin), weapons: double('weapons', create: mock_weapon)) }

  before do
    allow(controller).to receive(:current_user).and_return(mock_user)
    allow(mock_skin).to receive(:image).and_return(mock_image)
    allow(File).to receive(:open).and_return(double('file', read: 'image data'))
  end

  describe 'POST #update_archetype' do
    context 'with valid archetype' do
      it 'creates a skin and weapon, then returns success' do
        post :update_archetype, params: { archetype: 'Attacker' }

        expect(response).to have_http_status(:success)
        expect(response.body).to include('"success":true')
        expect(mock_user.skins).to have_received(:build)
        expect(mock_user.weapons).to have_received(:create)
      end
    end

    context 'with invalid archetype' do
      it 'returns an error message' do
        post :update_archetype, params: { archetype: 'InvalidArchetype' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('"success":false')
        expect(response.body).to include('Invalid archetype selected')
      end
    end

    context 'when skin creation fails' do
      it 'returns an error message when skin cannot be saved' do
        allow(mock_skin).to receive(:save).and_return(false)

        post :update_archetype, params: { archetype: 'Defender' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('"success":false')
        expect(response.body).to include("Failed to save skin")
      end
    end

    context 'when weapon creation fails' do
      it 'returns an error message when weapon cannot be saved' do
        allow(mock_weapon).to receive(:save).and_return(false)

        post :update_archetype, params: { archetype: 'Healer' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('"success":false')
        expect(response.body).to include("Failed to save weapon")
      end
    end

    context 'when an unexpected error occurs' do
      it 'returns a 500 error with the exception message' do
        allow(controller).to receive(:select_skin_image).and_raise(StandardError, 'Something went wrong')

        post :update_archetype, params: { archetype: 'Attacker' }

        expect(response).to have_http_status(:internal_server_error)
        expect(response.body).to include('"success":false')
        expect(response.body).to include('Something went wrong')
      end
    end
  end
end
