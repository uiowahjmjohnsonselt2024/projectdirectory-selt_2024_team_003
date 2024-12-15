require 'rails_helper'

RSpec.describe Weapon, type: :model do
  let(:user) do
    User.create!(
      username: "testuser",
      email: "test@example.com",
      password: "password123"
    )
  end

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }

    context 'custom validation: only_one_current_weapon' do
      it 'allows one current weapon per user' do
        weapon1 = user.weapons.create!(name: "Sword", current: true)
        weapon2 = user.weapons.build(name: "Axe", current: true)

        expect(weapon2.valid?).to be_falsey
        expect(weapon2.errors[:current]).to include('There can only be one current weapon for a user.')
      end

      it 'allows multiple weapons if only one is current' do
        weapon1 = user.weapons.create!(name: "Sword", current: true)
        weapon2 = user.weapons.build(name: "Axe", current: false)

        expect(weapon2.valid?).to be_truthy
      end
    end
  end

  describe '#set_as_current_weapon' do
    it 'sets the current weapon and unsets other weapons' do
      weapon1 = user.weapons.create!(name: "Sword", current: true)
      weapon2 = user.weapons.create!(name: "Axe", current: false)

      expect(weapon1.current).to be_truthy
      expect(weapon2.current).to be_falsey

      weapon2.set_as_current_weapon

      weapon1.reload
      weapon2.reload

      expect(weapon1.current).to be_falsey
      expect(weapon2.current).to be_truthy
    end

    it 'raises an error if the update fails' do
      weapon = user.weapons.create!(name: "Sword", current: false)

      allow(weapon).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)

      expect { weapon.set_as_current_weapon }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
