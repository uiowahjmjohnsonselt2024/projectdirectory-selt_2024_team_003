require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'friendship functionality' do
    let(:user) { User.create(username: 'user1', email: 'user1@example.com', password: 'password') }
    let(:friend) { User.create(username: 'user2', email: 'user2@example.com', password: 'password') }

    context 'adding a friend' do
      it 'adds a friend successfully' do
        expect {
          user.friendships.create(friend: friend)
        }.to change { user.friends.count }.by(1)
      end

      it 'does not allow duplicate friendships' do
        user.friendships.create(friend: friend)
        duplicate_friendship = user.friendships.build(friend: friend)

        expect(duplicate_friendship).not_to be_valid
        expect(duplicate_friendship.errors[:user_id]).to include('You are already friends with this user.')
      end
    end

    context 'removing a friend' do
      before do
        user.friendships.create(friend: friend)
      end

      it 'removes a friend successfully' do
        expect {
          user.friendships.find_by(friend: friend).destroy
        }.to change { user.friends.count }.by(-1)
      end
    end
  end
end
