# spec/controllers/chats_controller_spec.rb

require 'rails_helper'

RSpec.describe ChatsController, type: :controller do
  let(:mock_user) { instance_double(User, id: 1, username: 'TestUser') }
  let(:mock_friend) { instance_double(User, id: 2, username: 'FriendUser') }
  let(:valid_message_params) { { content: 'Hello, friend!' } }
  let(:invalid_message_params) { { content: nil } }

  before do
    allow(controller).to receive(:current_user).and_return(mock_user)
    allow(User).to receive(:find).with(mock_user.id.to_s).and_return(mock_user)
    allow(User).to receive(:find).with(mock_friend.id.to_s).and_return(mock_friend)
  end

  describe 'GET #show' do
    it 'assigns the correct friend and messages' do
      # Mock the where queries and chain them to support 'or' method
      messages1 = double('Message::ActiveRecord_Relation')
      messages2 = double('Message::ActiveRecord_Relation')

      # Set up Message.where to return different queries
      allow(Message).to receive(:where).and_return(messages1)
      allow(messages1).to receive(:or).and_return(messages2)
      allow(messages2).to receive(:order).and_return(messages2)  # Mock the order method

      get :show, params: { friend_id: mock_friend.id }

      expect(assigns(:friend)).to eq(mock_friend)
      expect(assigns(:messages)).to eq(messages2)  # Expect messages2 because it was the final chain
      expect(assigns(:new_message)).to be_a_new(Message)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new message and redirects to the chat page' do
        message = instance_double(Message, save: true)

        # Allow setting recipient_id on the mock Message
        allow(message).to receive(:recipient_id=).with(mock_friend.id.to_s)
        allow(message).to receive(:save).and_return(true)

        # Mock the sent_messages relation to return a collection that responds to 'build'
        sent_messages = double('ActiveRecord::Associations::CollectionProxy')
        allow(mock_user).to receive(:sent_messages).and_return(sent_messages)
        allow(sent_messages).to receive(:build).and_return(message)  # Mock build method

        # Mock the add_achievement method
        allow(mock_user).to receive(:add_achievement)

        post :create, params: { friend_id: mock_friend.id, message: valid_message_params }

        expect(flash[:notice]).to eq('Message sent!')
        expect(response).to redirect_to(chat_with_user_path(friend_id: mock_friend.id))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new message and shows an alert' do
        message = instance_double(Message, save: false)

        # Allow setting recipient_id on the mock Message
        allow(message).to receive(:recipient_id=).with(mock_friend.id.to_s)
        allow(message).to receive(:save).and_return(false)

        sent_messages = double('ActiveRecord::Associations::CollectionProxy')
        allow(mock_user).to receive(:sent_messages).and_return(sent_messages)
        allow(sent_messages).to receive(:build).and_return(message)  # Mock build method

        post :create, params: { friend_id: mock_friend.id, message: invalid_message_params }

        expect(flash[:alert]).to eq('Failed to send the message.')
        expect(response).to redirect_to(chat_with_user_path(friend_id: mock_friend.id))
      end
    end
  end

  describe 'POST #mark_as_read' do
    it 'marks all unread messages as read' do
      messages = double('Message::ActiveRecord_Relation')  # Mocking an ActiveRecord relation
      allow(Message).to receive(:where).and_return(messages)
      allow(messages).to receive(:update_all).and_return(true)  # Mocking update_all

      post :mark_as_read, params: { friend_id: mock_friend.id }

      expect(response).to have_http_status(:ok)
    end
  end
end
