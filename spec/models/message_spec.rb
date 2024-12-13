# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:user) { create(:user) }
  let(:recipient) { create(:user) }
  let(:message) { create(:message, user: user, recipient: recipient, content: 'Hello!') }

  describe 'validations' do
    it 'validates presence of content' do
      invalid_message = build(:message, user: user, recipient: recipient, content: nil)

      expect(invalid_message).not_to be_valid
      expect(invalid_message.errors[:content]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'belongs to a user' do
      expect(message.user).to eq(user)
    end

    it 'belongs to a recipient' do
      expect(message.recipient).to eq(recipient)
    end
  end
end
