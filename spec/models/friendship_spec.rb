require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }

  describe 'validations' do
    it 'validates uniqueness of friendship' do
      # Create a friendship between user and friend
      create(:friendship, user: user, friend: friend)

      # Try to create the same friendship again
      duplicate_friendship = build(:friendship, user: user, friend: friend)

      expect(duplicate_friendship).not_to be_valid
      expect(duplicate_friendship.errors[:user_id]).to include("You are already friends with this user.")
    end
  end
end
