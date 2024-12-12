# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GameUser, type: :model do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:game_user) { create(:game_user, user: user, game: game, x_position: 0, y_position: 0) }

  describe '#move_to' do
    context 'when the new position is adjacent' do
      it 'updates the position and returns true' do
        result = game_user.move_to(1, 1)
        expect(result).to be true
        expect(game_user.x_position).to eq(1)
        expect(game_user.y_position).to eq(1)
      end
    end

    context 'when the new position is not adjacent' do
      it 'does not update the position and returns false' do
        result = game_user.move_to(3, 3)
        expect(result).to be false
        expect(game_user.x_position).to eq(0)
        expect(game_user.y_position).to eq(0)
      end
    end
  end

  describe 'validations' do
    it 'validates numericality of x_position and y_position' do
      invalid_game_user = GameUser.new(user: user, game: game, x_position: 'a', y_position: 'b')
      expect(invalid_game_user.valid?).to be false
      expect(invalid_game_user.errors[:x_position]).to include('is not a number')
      expect(invalid_game_user.errors[:y_position]).to include('is not a number')
    end
  end
  describe '#update_health' do
    it 'updates health to match the user health' do
      user = create(:user, health: 150)
      game_user = create(:game_user, user: user, health: 100)
      game_user.update_health

      expect(game_user.health).to eq(150)
    end
  end

  describe '#take_damage' do
    it 'reduces health when damage is taken' do
      game_user = create(:game_user, health: 100)
      game_user.take_damage(30)

      expect(game_user.health).to eq(70)
    end
  end
end
