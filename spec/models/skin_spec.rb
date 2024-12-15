require 'rails_helper'

RSpec.describe Skin, type: :model do
  let(:user) { User.create!(email: 'test@example.com', password: 'password', username: 'testuser') }

  describe 'Validations' do
    it 'validates the presence of archetype' do
      skin = Skin.new(user: user, archetype: nil)
      expect(skin.valid?).to be_falsey
      expect(skin.errors[:archetype]).to include("can't be blank")
    end

    it 'validates inclusion of archetype in allowed values' do
      skin = Skin.new(user: user, archetype: 'InvalidArchetype')
      expect(skin.valid?).to be_falsey
      expect(skin.errors[:archetype]).to include("InvalidArchetype is not a valid archetype")
    end

    it 'validates only one skin can be marked as current' do
      Skin.create!(user: user, archetype: 'Attacker', current: true)
      another_skin = Skin.new(user: user, archetype: 'Defender', current: true)
      expect(another_skin.valid?).to be_falsey
      expect(another_skin.errors[:current]).to include('There can only be one current skin for a user.')
    end
  end

  describe 'Default stats' do
    it 'sets default stats based on archetype' do
      skin = Skin.new(user: user, archetype: 'Attacker')
      skin.set_default_stats
      expect(skin.attack).to eq(30)
      expect(skin.defense).to eq(5)
      expect(skin.iq).to eq(10)
      expect(skin.mana).to eq(100)
      expect(skin.health).to eq(100)
    end
  end

  describe '#level_up' do
    it 'increases stats based on archetype and levels up' do
      skin = Skin.create!(user: user, archetype: 'Defender', level: 1, experience: 120)
      skin.level_up
      expect(skin.level).to eq(2)
      expect(skin.health).to eq(230) # 200 + 30
      expect(skin.attack).to eq(15) # 10 + 5
    end
  end

  describe '#set_as_current_skin' do
    it 'sets the skin as the current one and unmarks others' do
      other_skin = Skin.create!(user: user, archetype: 'Healer', current: true)
      new_skin = Skin.create!(user: user, archetype: 'Attacker')
      new_skin.set_as_current_skin
      expect(new_skin.reload.current).to be_truthy
      expect(other_skin.reload.current).to be_falsey
    end
  end
end
