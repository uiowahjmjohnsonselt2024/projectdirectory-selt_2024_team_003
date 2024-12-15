require 'rails_helper'

RSpec.describe Weapon, type: :model do
  describe "validations" do
    let(:user) { create(:user) } # Assuming a User factory exists

    it "is valid with a name and user" do
      weapon = Weapon.new(name: "Sword", user: user)
      expect(weapon).to be_valid
    end

    it "is invalid without a name" do
      weapon = Weapon.new(name: nil, user: user)
      expect(weapon).to_not be_valid
      expect(weapon.errors[:name]).to include("can't be blank")
    end

    it "is valid when no other weapon is marked as current" do
      weapon = Weapon.new(name: "Sword", user: user, current: true)
      expect(weapon).to be_valid
    end

    it "is invalid when another weapon is already marked as current" do
      create(:weapon, name: "Bow", user: user, current: true)
      weapon = Weapon.new(name: "Sword", user: user, current: true)

      expect(weapon).to_not be_valid
      expect(weapon.errors[:current]).to include("There can only be one current weapon for a user.")
    end
  end

  describe "#set_as_current_weapon" do
    let(:user) { create(:user) }
    let!(:weapon1) { create(:weapon, name: "Sword", user: user, current: true) }
    let!(:weapon2) { create(:weapon, name: "Bow", user: user, current: false) }

    it "sets the weapon as current and resets others" do
      weapon2.set_as_current_weapon

      expect(weapon2.reload.current).to be true
      expect(weapon1.reload.current).to be false
    end
  end

  describe "edge cases" do
    let(:user) { create(:user) }

    it "allows creating a non-current weapon when another is current" do
      create(:weapon, name: "Sword", user: user, current: true)
      weapon = Weapon.new(name: "Bow", user: user, current: false)

      expect(weapon).to be_valid
    end

    it "does not allow setting multiple weapons as current" do
      create(:weapon, name: "Sword", user: user, current: true)
      weapon = create(:weapon, name: "Bow", user: user, current: false)

      weapon.update(current: true)

      expect(weapon.errors[:current]).to include("There can only be one current weapon for a user.")
    end

    it "handles setting a current weapon when there are no current weapons" do
      weapon = create(:weapon, name: "Axe", user: user, current: false)
      weapon.set_as_current_weapon

      expect(weapon.reload.current).to be true
    end
  end
end