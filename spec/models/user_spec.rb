require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = User.new(
      username: 'testuser',
      email: 'testuser@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(@user).to be_valid
    end

    it 'is invalid without a username' do
      @user.username = nil
      expect(@user).to_not be_valid
      expect(@user.errors[:username]).to include('Username is required')
    end

    it 'is invalid if username is not unique' do
      User.create(username: 'testuser', email: 'unique@example.com', password: 'password')
      expect(@user).to_not be_valid
      expect(@user.errors[:username]).to include('Username has already been taken')
    end

    it 'is invalid if username length is less than 3 or greater than 20' do
      @user.username = 'aa'
      expect(@user).to_not be_valid
      expect(@user.errors[:username]).to include('Username must be between 3 and 20 characters')

      @user.username = 'a' * 21
      expect(@user).to_not be_valid
    end

    it 'is invalid without an email' do
      @user.email = nil
      expect(@user).to_not be_valid
      expect(@user.errors[:email]).to include('Email is required')
    end

    it 'is invalid if email format is incorrect' do
      @user.email = 'invalid_email'
      expect(@user).to_not be_valid
      expect(@user.errors[:email]).to include('Invalid email format')
    end

    it 'is invalid if email is not unique' do
      User.create(username: 'uniqueuser', email: 'testuser@example.com', password: 'password')
      expect(@user).to_not be_valid
      expect(@user.errors[:email]).to include('Email has already been taken')
    end

    it 'is invalid if password is less than 6 characters' do
      @user.password = '12345'
      expect(@user).to_not be_valid
      expect(@user.errors[:password]).to include('Password must be at least 6 characters long')
    end
  end

  describe 'associations' do
    it { should have_many(:game_users) }
    it { should have_many(:games).through(:game_users) }
  end

  describe 'custom methods' do
    describe '#generate_reset_password_token!' do
      it 'generates a reset password token and sets the time' do
        @user.save!
        expect(@user.reset_password_token).to be_nil
        expect(@user.reset_password_sent_at).to be_nil

        @user.generate_reset_password_token!
        expect(@user.reset_password_token).to be_present
        expect(@user.reset_password_sent_at).to be_within(1.second).of(Time.now.utc)
      end
    end
    end

    describe '#reset_password_token_valid?' do
      it 'returns true for a valid token' do
        @user.save!
        @user.generate_reset_password_token!
        expect(@user.reset_password_token_valid?(@user.reset_password_token)).to be true
      end

      it 'returns false for an invalid token' do
        @user.save!
        @user.generate_reset_password_token!
        expect(@user.reset_password_token_valid?('invalidtoken')).to be false
      end
    end

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

      it 'sets stats for Attacker' do
        user.set_archetype_stats('Attacker')
        expect(user.attack).to eq(30)
        expect(user.iq).to eq(10)
        expect(user.defense).to eq(5)
        expect(user.health).to eq(100)
      end

      it 'sets stats for Defender' do
        user.set_archetype_stats('Defender')
        expect(user.attack).to eq(10)
        expect(user.iq).to eq(1)
        expect(user.defense).to eq(30)
        expect(user.health).to eq(200)
      end

      it 'sets stats for Healer' do
        user.set_archetype_stats('Healer')
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
        expect(user.health).to eq(120) # +20 for Attacker
        expect(user.attack).to eq(20) # +10 for Attacker
        expect(user.defense).to eq(10) # +5 for Attacker
        expect(user.iq).to eq(4) # +3 for Attacker
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

