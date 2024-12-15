require 'rails_helper'

RSpec.describe Consumable, type: :model do
  describe "validations" do
    let(:user) { create(:user) } # Assuming a User factory exists

    it "is valid with a non-negative quantity" do
      consumable = Consumable.new(quantity: 10, user: user)
      expect(consumable).to be_valid
    end

    it "is valid with a quantity of zero" do
      consumable = Consumable.new(quantity: 0, user: user)
      expect(consumable).to be_valid
    end

    it "is invalid with a negative quantity" do
      consumable = Consumable.new(quantity: -5, user: user)
      expect(consumable).to_not be_valid
      expect(consumable.errors[:quantity]).to include("must be greater than or equal to 0")
    end
  end

  describe "#increment_quantity" do
    let(:consumable) { Consumable.create(quantity: 10, user: create(:user)) }

    it "increases the quantity by 1 by default" do
      expect { consumable.increment_quantity }.to change { consumable.quantity }.from(10).to(11)
    end

    it "increases the quantity by a custom amount" do
      expect { consumable.increment_quantity(5) }.to change { consumable.quantity }.from(10).to(15)
    end

    it "persists the updated quantity" do
      consumable.increment_quantity(3)
      expect(consumable.reload.quantity).to eq(13)
    end
  end

  describe "#decrement_quantity" do
    let(:consumable) { Consumable.create(quantity: 10, user: create(:user)) }

    it "decreases the quantity by 1 by default" do
      expect { consumable.decrement_quantity }.to change { consumable.quantity }.from(10).to(9)
    end

    it "decreases the quantity by a custom amount" do
      expect { consumable.decrement_quantity(4) }.to change { consumable.quantity }.from(10).to(6)
    end

    it "does not change the quantity if it is already 0" do
      consumable.update(quantity: 0)
      expect { consumable.decrement_quantity }.not_to change { consumable.quantity }
      expect(consumable.reload.quantity).to eq(0)
    end
  end

  describe "edge cases" do
    it "increments correctly from zero quantity" do
      consumable = Consumable.create(quantity: 0, user: create(:user))
      expect { consumable.increment_quantity }.to change { consumable.quantity }.from(0).to(1)
    end

    it "decrements correctly to zero" do
      consumable = Consumable.create(quantity: 1, user: create(:user))
      expect { consumable.decrement_quantity }.to change { consumable.quantity }.from(1).to(0)
    end

    it "handles large increments" do
      consumable = Consumable.create(quantity: 1000, user: create(:user))
      expect { consumable.increment_quantity(10000) }.to change { consumable.quantity }.from(1000).to(11000)
    end
  end
end