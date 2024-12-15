require 'rails_helper'

RSpec.describe GameUser, type: :model do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:current_skin) { double('Skin', health: 100, mana: 50, level: 1) }

  before do
    allow(user).to receive(:current_skin).and_return(current_skin)
  end

  subject { create(:game_user, user: user, game: game, x_position: 0, y_position: 0) }

  describe 'validations' do
    it { should validate_presence_of(:x_position) }
    it { should validate_presence_of(:y_position) }
    it { should validate_numericality_of(:x_position).only_integer }
    it { should validate_numericality_of(:y_position).only_integer }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:game) }
  end

  describe '#move_to' do
    context 'when moving within one step' do
      it 'updates the position and grants an achievement if leaving the starting position' do
        expect(user).to receive(:add_achievement).with('Explorer: The first step is always the bravest. Welcome to the unknown.')
        expect(subject.move_to(1, 1)).to be true
        expect(subject.x_position).to eq(1)
        expect(subject.y_position).to eq(1)
      end

      it 'does not grant an achievement if not leaving the starting position' do
        subject.update(x_position: 1, y_position: 1)
        expect(user).not_to receive(:add_achievement)
        expect(subject.move_to(2, 2)).to be true
      end
    end

    context 'when moving out of bounds' do
      it 'does not update the position if moving more than one step' do
        expect(subject.move_to(3, 3)).to be false
        expect(subject.x_position).to eq(0)
        expect(subject.y_position).to eq(0)
      end
    end
  end

  describe '#update_health_and_mana' do
    context 'when user has a current skin' do
      it 'updates health, mana, and level' do
        subject.update_health_and_mana
        expect(subject.health).to eq(100)
        expect(subject.mana).to eq(50)
        expect(subject.level).to eq(1)
      end
    end

    context 'when user does not have a current skin' do
      before do
        allow(user).to receive(:current_skin).and_return(nil)
      end

      it 'raises an error' do
        expect { subject.update_health_and_mana }.to raise_error('User does not have a current skin')
      end
    end
  end

  describe '#set_health_and_mana' do
    context 'when user has a current skin' do
      it 'sets health and mana on creation' do
        expect(subject.health).to eq(100)
        expect(subject.mana).to eq(50)
      end
    end

    context 'when user does not have a current skin' do
      before do
        allow(user).to receive(:current_skin).and_return(nil)
      end

      it 'raises an error' do
        expect { subject.save! }.to raise_error('User does not have a current skin')
      end
    end
  end

  describe '#take_damage' do
    it 'reduces health by the damage amount' do
      subject.take_damage(20)
      expect(subject.health).to eq(80)
    end
  end

  describe '#use_mana' do
    context 'when enough mana is available' do
      it 'reduces mana and returns true' do
        expect(subject.use_mana(10)).to be true
        expect(subject.mana).to eq(40)
      end
    end

    context 'when not enough mana is available' do
      it 'does not reduce mana and returns false' do
        expect(subject.use_mana(60)).to be false
        expect(subject.mana).to eq(50)
      end
    end
  end
end
