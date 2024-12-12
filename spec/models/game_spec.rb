# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      game = Game.new(name: 'Test Game')
      expect(game).to be_valid
    end

    it 'is invalid without a name' do
      game = Game.new(name: nil)
      expect(game).not_to be_valid
      expect(game.errors[:name]).to include("can't be blank")
    end

    it 'is invalid with a name longer than 50 characters' do
      game = Game.new(name: 'A' * 51)
      expect(game).not_to be_valid
      expect(game.errors[:name]).to include('is too long (maximum is 50 characters)')
    end

    it 'is valid with a name that is exactly 50 characters' do
      game = Game.new(name: 'A' * 50)
      expect(game).to be_valid
    end

    it 'is invalid if the code is not unique' do
      Game.create(name: 'Game One', code: 'ABCD')
      duplicate_game = Game.new(name: 'Game Two', code: 'ABCD')
      expect(duplicate_game).not_to be_valid
      expect(duplicate_game.errors[:code]).to include('has already been taken')
    end
  end

  describe 'callbacks' do
    it 'generates a unique 4-character code before creation if code is not provided' do
      game = Game.create(name: 'Game with Auto Code')
      expect(game.code).to be_present
      expect(game.code.length).to eq(4)
      expect(game.code).to match(/\A[A-Z0-9]{4}\z/)
    end

    it 'does not overwrite an existing code' do
      game = Game.create(name: 'Game with Predefined Code', code: 'TEST')
      expect(game.code).to eq('TEST')
    end

    it 'ensures code uniqueness even with simultaneous creations' do
      game1 = Game.create(name: 'Game One')
      game2 = Game.create(name: 'Game Two')

      expect(game1.code).not_to eq(game2.code)
    end

    it 'retries code generation until a unique code is generated' do
      allow(SecureRandom).to receive(:alphanumeric).and_return('ABCD', 'EFGH', 'ABCD', 'WXYZ')
      Game.create(name: 'Game One', code: 'ABCD') # Pre-existing game with code 'ABCD'
      game = Game.create(name: 'Game Two')

      expect(game.code).to eq('EFGH').or(eq('WXYZ'))
    end
  end
  describe '#generate_enemies' do
    it 'creates enemies for the grid with correct attributes' do
      game = Game.create(name: 'Game with Enemies')
      enemies = game.enemies

      expect(enemies.count).to eq(100) # 10x10 grid
      enemies.each do |enemy|
        level = (enemy.x_position * 3) + enemy.y_position + 1
        expect(enemy.health).to eq(300 + (level * 20))
        expect(enemy.attack).to eq(20 + (level * 2))
        expect(enemy.defense).to eq(10 + (level * 2))
        expect(enemy.iq).to eq(5 + level)
        expect(enemy.max_health).to eq(300 + (level * 20))
        expect(enemy.level).to eq(level)
      end
    end
  end
end
