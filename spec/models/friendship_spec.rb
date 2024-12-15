require 'rails_helper'

RSpec.describe Friendship, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:friend).class_name('User') }
  end

  describe 'validations' do
    let!(:user) { User.create!(email: 'user1@example.com', username: 'user1', password: 'password') }
    let!(:friend) { User.create!(email: 'user2@example.com', username: 'user2', password: 'password') }

    it 'validates uniqueness of user_id scoped to friend_id' do
      Friendship.create!(user: user, friend: friend)
      duplicate_friendship = Friendship.new(user: user, friend: friend)

      expect(duplicate_friendship).not_to be_valid
      expect(duplicate_friendship.errors[:user_id]).to include('You are already friends with this user.')
    end
  end

  context 'when creating friendships' do
    let!(:user) { User.create!(email: 'alice@example.com', username: 'alice', password: 'password') }
    let!(:friend) { User.create!(email: 'bob@example.com', username: 'bob', password: 'password') }

    it 'allows creating a new friendship' do
      friendship = Friendship.create!(user: user, friend: friend)
      expect(friendship).to be_persisted
      expect(friendship.user).to eq(user)
      expect(friendship.friend).to eq(friend)
    end

    it 'does not allow duplicate friendships' do
      Friendship.create!(user: user, friend: friend)
      duplicate_friendship = Friendship.new(user: user, friend: friend)

      expect(duplicate_friendship).not_to be_valid
      expect(duplicate_friendship.errors[:user_id]).to include('You are already friends with this user.')
    end
  end
end
