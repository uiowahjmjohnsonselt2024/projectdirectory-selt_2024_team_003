require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:sender) { User.create(email: "sender@example.com", password: "password") }
  let(:recipient) { User.create(email: "recipient@example.com", password: "password") }

  context "associations" do
    it "belongs to a user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to a recipient" do
      association = described_class.reflect_on_association(:recipient)
      expect(association.macro).to eq(:belongs_to)
      expect(association.class_name).to eq('User')
    end
  end

  context "validations" do
    it "is valid with valid attributes" do
      message = Message.new(content: "Hello", user: sender, recipient: recipient)
      expect(message).to be_valid
    end

    it "is not valid without content" do
      message = Message.new(content: nil, user: sender, recipient: recipient)
      expect(message).not_to be_valid
      expect(message.errors[:content]).to include("can't be blank")
    end
  end
end
