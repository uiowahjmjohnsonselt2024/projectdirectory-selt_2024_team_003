# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enemy, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      enemy = Enemy.new(name: 'Test Enemy', x_position: 0, y_position: 0, level: 1)
      expect(enemy).to be_valid
    end

    it 'is invalid without numerical stats' do
      enemy = Enemy.new(name: 'Test Enemy', x_position: 0, y_position: 0, level: 1)
      enemy.health = nil
      enemy.valid?
      expect(enemy.errors[:health]).to include("can't be blank")
    end

    it 'is invalid with non-integer stats' do
      enemy = Enemy.new(name: 'Test Enemy', x_position: 0, y_position: 0, level: 1)
      enemy.health = 'not a number'
      enemy.valid?
      expect(enemy.errors[:health]).to include('is not a number')
    end

    it 'is invalid with a level less than 1' do
      enemy = Enemy.new(name: 'Test Enemy', x_position: 0, y_position: 0, level: 0)
      expect(enemy).not_to be_valid
      expect(enemy.errors[:level]).to include('must be greater than or equal to 1')
    end
  end

  describe 'associations' do
    it 'belongs to a game' do
      game = Game.create(name: 'Test Game')
      enemy = Enemy.create(name: 'Test Enemy', x_position: 0, y_position: 0, level: 1, game: game)
      expect(enemy.game).to eq(game)
    end
  end

  describe 'image attachment' do
    it 'allows valid image types' do
      enemy = Enemy.create(name: 'Test Enemy', x_position: 0, y_position: 0, level: 1)
      enemy.image.attach(io: File.open('spec/fixtures/files/test_image.png'), filename: 'test_image.png', content_type: 'image/png')
      expect(enemy.image).to be_attached
    end
  end

  describe 'callbacks' do
    it 'sets default stats after initialization' do
      enemy = Enemy.new(name: 'Test Enemy', x_position: 0, y_position: 0, level: 2)
      expect(enemy.health).to eq(340)
      expect(enemy.attack).to eq(24)
      expect(enemy.defense).to eq(14)
      expect(enemy.iq).to eq(7)
      expect(enemy.special_attack).to eq(21)
      expect(enemy.special_defense).to eq(14)
      expect(enemy.mana).to eq(60)
      expect(enemy.max_health).to eq(340)
      expect(enemy.max_mana).to eq(60)
    end

    it 'handles large level values correctly' do
      enemy = Enemy.new(name: 'Test Enemy', x_position: 0, y_position: 0, level: 1000)
      expect(enemy.health).to eq(20300)
      expect(enemy.attack).to eq(2020)
      expect(enemy.defense).to eq(2010)
      expect(enemy.iq).to eq(1005)
      expect(enemy.special_attack).to eq(3015)
      expect(enemy.special_defense).to eq(2010)
      expect(enemy.mana).to eq(5050)
      expect(enemy.max_health).to eq(20300)
      expect(enemy.max_mana).to eq(5050)
    end
  end

  describe 'methods' do
    describe '#use_mana' do
      it 'reduces mana when amount is within range' do
        enemy = Enemy.create(name: 'Test Enemy', x_position: 0, y_position: 0, level: 1)
        expect(enemy.use_mana(10)).to be true
        expect(enemy.reload.mana).to eq(45)
      end

      it 'does not reduce mana when amount exceeds current mana' do
        enemy = Enemy.create(name: 'Test Enemy', x_position: 0, y_position: 0, level: 1)
        expect(enemy.use_mana(60)).to be false
        expect(enemy.reload.mana).to eq(55)
      end

      it 'uses all mana when amount equals current mana' do
        enemy = Enemy.create(name: 'Test Enemy', x_position: 0, y_position: 0, level: 1)
        expect(enemy.use_mana(55)).to be true
        expect(enemy.reload.mana).to eq(0)
      end

      it 'does not modify mana when amount is zero' do
        enemy = Enemy.create(name: 'Test Enemy', x_position: 0, y_position: 0, level: 1)
        expect(enemy.use_mana(0)).to be true
        expect(enemy.reload.mana).to eq(55)
      end
    end
  end
end
