# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) do
    User.create(
      username: 'TestUser',
      email: 'test@example.com',
      password: 'password',
      health: 100,
      attack: 50,
      defense: 40,
      iq: 120,
      shards: 0,
      level: 1
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is invalid without a username' do
      user.username = nil
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("Username is required")
    end

    it 'is invalid with a duplicate username' do
      User.create(username: 'TestUser', email: 'duplicate@example.com', password: 'password', health: 100, attack: 50, defense: 40, iq: 120)
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("Username has already been taken")
    end

    it 'is invalid without an email' do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("Email is required")
    end

    it 'is invalid with a duplicate email' do
      User.create(username: 'OtherUser', email: 'test@example.com', password: 'password', health: 100, attack: 50, defense: 40, iq: 120)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("Email has already been taken")
    end

    it 'is invalid with an improperly formatted email' do
      user.email = 'invalid-email'
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("Invalid email format")
    end

    it 'is invalid with a short password' do
      user.password = 'short'
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("Password must be at least 6 characters long")
    end

    it 'is invalid without numeric attributes' do
      user.health = nil
      user.attack = nil
      user.defense = nil
      user.iq = nil
      expect(user).not_to be_valid
    end
  end

  describe '#initialize_achievements' do
    it 'initializes achievements to an empty array if nil' do
      user.achievements = nil
      user.save
      expect(user.achievements).to eq([])
    end
  end

  describe '#add_achievement' do
    it 'adds a new achievement and increases shards' do
      expect { user.add_achievement('First Win') }.to change { user.shards }.by(12)
      expect(user.achievements).to include('First Win')
    end

    it 'does not add a duplicate achievement' do
      user.add_achievement('First Win')
      expect { user.add_achievement('First Win') }.not_to change { user.shards }
    end
  end

  describe '#has_achievement' do
    it 'returns true if the user has the achievement' do
      user.add_achievement('First Win')
      expect(user.has_achievement('First Win')).to be_truthy
    end

    it 'returns false if the user does not have the achievement' do
      expect(user.has_achievement('Nonexistent Achievement')).to be_falsey
    end
  end

  describe '#check_milestone_achievements' do
    it 'adds the correct milestone achievement based on level' do
      user.level = 10
      expect { user.check_milestone_achievements }.to change { user.achievements }.to include('Level 10: Experienced Warrior')
    end

    it 'does not add an achievement if no milestone matches the level' do
      expect { user.check_milestone_achievements }.not_to change { user.achievements }
    end
  end

  describe '#has_credit_card?' do
    it 'returns true if the user has a credit card' do
      user.create_credit_card(card_number: '1234567890123456', cvv: '123')
      expect(user.has_credit_card?).to be_truthy
    end

    it 'returns false if the user does not have a credit card' do
      expect(user.has_credit_card?).to be_falsey
    end
  end

  describe '#generate_reset_password_token!' do
    it 'generates a reset password token and sets the expiration time' do
      expect { user.generate_reset_password_token! }.to change { user.reset_password_token }.from(nil)
      expect(user.reset_password_sent_at).to be_within(1.second).of(Time.now.utc)
    end
  end

  describe '#reset_password_token_valid?' do
    it 'returns true if the token matches and is within the valid timeframe' do
      user.generate_reset_password_token!
      expect(user.reset_password_token_valid?(user.reset_password_token)).to be_truthy
    end

    it 'returns false if the token does not match' do
      user.generate_reset_password_token!
      expect(user.reset_password_token_valid?('invalid_token')).to be_falsey
    end

    it 'returns false if the token has expired' do
      user.generate_reset_password_token!
      user.update(reset_password_sent_at: 2.hours.ago)
      expect(user.reset_password_token_valid?(user.reset_password_token)).to be_falsey
    end
  end

  describe '#current_skin' do
    it 'returns the current skin of the user' do
      user.skins.create(style: 'Default', current: true)
      expect(user.current_skin.style).to eq('Default')
    end

    it 'returns nil if no current skin is set' do
      expect(user.current_skin).to be_nil
    end
  end
end
