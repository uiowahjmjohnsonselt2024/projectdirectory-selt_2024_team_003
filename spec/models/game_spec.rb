require 'rails_helper'

RSpec.describe Game, type: :model do
  describe "validations" do
    it "is valid with a valid name and unique code" do
      game = Game.new(name: "Test Game")
      expect(game).to be_valid
    end

    it "is invalid without a name" do
      game = Game.new(name: nil)
      expect(game).not_to be_valid
      expect(game.errors[:name]).to include("can't be blank")
    end

    it "is invalid with a name longer than 50 characters" do
      game = Game.new(name: "a" * 51)
      expect(game).not_to be_valid
      expect(game.errors[:name]).to include("is too long (maximum is 50 characters)")
    end

    it "is valid with a name of 50 characters or less" do
      game = Game.new(name: "a" * 50)
      expect(game).to be_valid
    end

    it "is invalid with a duplicate code" do
      existing_game = Game.create!(name: "Existing Game", code: "UNIQ")
      new_game = Game.new(name: "New Game", code: "UNIQ")
      expect(new_game).not_to be_valid
      expect(new_game.errors[:code]).to include("has already been taken")
    end
  end

  describe "associations" do
    it { should have_many(:game_users).dependent(:destroy) }
    it { should have_many(:users).through(:game_users) }
    it { should have_many(:enemies).dependent(:destroy) }
  end

  describe "callbacks" do
    context "before_create :generate_unique_code" do
      it "generates a unique 4-character code before creation" do
        game = Game.create!(name: "Test Game")
        expect(game.code).to be_present
        expect(game.code.length).to eq(4)
      end

      it "ensures the code is unique" do
        existing_game = Game.create!(name: "Existing Game", code: "DUP1")
        allow(SecureRandom).to receive(:alphanumeric).and_return("DUP1", "UNIQ")
        new_game = Game.create!(name: "New Game")
        expect(new_game.code).to eq("UNIQ")
      end
    end

    context "after_create :generate_enemies" do
      it "generates the correct number of enemies" do
        game = Game.create!(name: "Test Game")
        expect(game.enemies.count).to eq(100)
      end

      it "creates enemies with correct attributes" do
        game = Game.create!(name: "Test Game")

        # Check attributes for the first enemy
        first_enemy = game.enemies.first
        expect(first_enemy.name).to eq("Enemy 0,0")
        expect(first_enemy.x_position).to eq(0)
        expect(first_enemy.y_position).to eq(0)

        # Check attributes for the last enemy
        last_enemy = game.enemies.last
        expect(last_enemy.name).to eq("Enemy 9,9")
        expect(last_enemy.x_position).to eq(9)
        expect(last_enemy.y_position).to eq(9)

        # Avoid assuming specific logic for 'level', but ensure it exists
        expect(first_enemy.level).to be_present
        expect(last_enemy.level).to be_present
      end
    end
  end

  describe "private methods" do
    it "does not allow public access to generate_unique_code" do
      game = Game.new(name: "Test Game")
      expect { game.generate_unique_code }.to raise_error(NoMethodError)
    end

    it "does not allow public access to generate_enemies" do
      game = Game.new(name: "Test Game")
      expect { game.generate_enemies }.to raise_error(NoMethodError)
    end
  end
end
