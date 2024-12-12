# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enemy, type: :model do
  describe 'validations' do
    it 'has correct default attributes' do
      enemy = Enemy.create(name: 'Test Enemy', x_position: 0, y_position: 0, level: 1)

      expect(enemy.health).to eq(320)
      expect(enemy.attack).to eq(22)
      expect(enemy.defense).to eq(12)
      expect(enemy.iq).to eq(6)
      expect(enemy.max_health).to eq(320)
    end
  end
end
