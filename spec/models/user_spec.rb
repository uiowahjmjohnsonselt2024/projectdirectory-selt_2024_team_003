# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'friendship functionality' do
    let(:user) { User.create(username: 'user1', email: 'user1@example.com', password: 'password') }
    let(:friend) { User.create(username: 'user2', email: 'user2@example.com', password: 'password') }

    context 'adding a friend' do
      it 'adds a friend successfully' do
        expect do
          user.friendships.create(friend: friend)
        end.to change { user.friends.count }.by(1)
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
        expect do
          user.friendships.find_by(friend: friend).destroy
        end.to change { user.friends.count }.by(-1)
      end
    end

    describe '#set_archetype_stats' do
      let(:user) { create(:user) }

      it 'sets stats for Arcane Strategist' do
        user.set_archetype_stats('Arcane Strategist')
        expect(user.attack).to eq(30)
        expect(user.iq).to eq(10)
        expect(user.defense).to eq(5)
        expect(user.health).to eq(100)
      end

      it 'sets stats for Iron Guardian' do
        user.set_archetype_stats('Iron Guardian')
        expect(user.attack).to eq(10)
        expect(user.iq).to eq(1)
        expect(user.defense).to eq(30)
        expect(user.health).to eq(200)
      end

      it 'sets stats for Omni Knight' do
        user.set_archetype_stats('Omni Knight')
        expect(user.attack).to eq(20)
        expect(user.iq).to eq(5)
        expect(user.defense).to eq(20)
        expect(user.health).to eq(150)
      end
    end

    describe '#level_up' do
      let(:user) do
        create(:user, level: 1, experience: 100, health: 100, attack: 10, defense: 5, iq: 1,
                      archetype: 'Arcane Strategist')
      end

      it 'levels up and increases stats based on archetype' do
        user.level_up

        expect(user.level).to eq(2)
        expect(user.health).to eq(120) # +20 for Arcane Strategist
        expect(user.attack).to eq(20) # +10 for Arcane Strategist
        expect(user.defense).to eq(10) # +5 for Arcane Strategist
        expect(user.iq).to eq(4) # +3 for Arcane Strategist
        expect(user.experience).to eq(0) # Reset experience after leveling up
      end
    end

    describe '#shards' do
      it 'validates that shards cannot be negative' do
        user = build(:user, shards: -10)
        expect(user).not_to be_valid
      end
    end
  end
end
