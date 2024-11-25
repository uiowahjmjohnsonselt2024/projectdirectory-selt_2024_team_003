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
  end
end
