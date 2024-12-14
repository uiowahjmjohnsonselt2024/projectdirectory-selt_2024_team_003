require 'rails_helper'

RSpec.describe CreditCard, type: :model do
  describe "validations" do
    let(:valid_card_number) { "4111 1111 1111 1111" } # Properly formatted Visa card

    it "is valid with all attributes present and correct" do
      credit_card = CreditCard.new(
        card_number: valid_card_number,
        expiration_month: 12,
        expiration_year: Date.today.year + 1,
        last4: "1111",
        card_type: "Visa"
      )
      expect(credit_card).to be_valid
    end

    it "is valid with an expiration date in the future" do
      credit_card = CreditCard.new(
        card_number: valid_card_number,
        expiration_month: 6,
        expiration_year: Date.today.year + 5
      )
      expect(credit_card).to be_valid
    end

    it "is valid with an expiration date in the current month and year" do
      credit_card = CreditCard.new(
        card_number: valid_card_number,
        expiration_month: Date.today.month,
        expiration_year: Date.today.year
      )
      expect(credit_card).to be_valid
    end

    it "is invalid if expiration month is out of range" do
      credit_card = CreditCard.new(
        card_number: valid_card_number,
        expiration_month: 13,
        expiration_year: Date.today.year + 1
      )
      expect(credit_card).to_not be_valid
    end

    it "is invalid with a past expiration date" do
      credit_card = CreditCard.new(
        card_number: valid_card_number,
        expiration_month: Date.today.month - 1,
        expiration_year: Date.today.year
      )
      expect(credit_card).to_not be_valid
    end
  end

  describe "callbacks" do
    let(:valid_card_number) { "4111 1111 1111 1111" }

    it "sets last4 correctly before validation" do
      credit_card = CreditCard.new(
        card_number: valid_card_number,
        expiration_month: 12,
        expiration_year: Date.today.year + 1
      )
      credit_card.valid?
      expect(credit_card.last4).to eq("1111")
    end

    it "sets card_type correctly for a Visa card" do
      credit_card = CreditCard.new(
        card_number: valid_card_number,
        expiration_month: 12,
        expiration_year: Date.today.year + 1
      )
      credit_card.valid?
      expect(credit_card.card_type).to eq("Visa")
    end

    it "sets card_type to 'Unknown' for an unrecognized card" do
      credit_card = CreditCard.new(
        card_number: "7999 1234 5678 9012",
        expiration_month: 12,
        expiration_year: Date.today.year + 1
      )
      credit_card.valid?
      expect(credit_card.card_type).to eq("Unknown")
    end
  end

  describe "edge cases" do
    it "is valid with a card number containing only spaces where expected" do
      credit_card = CreditCard.new(
        card_number: "1234 5678 9012 3456",
        expiration_month: 5,
        expiration_year: Date.today.year + 3
      )
      expect(credit_card).to be_valid
    end

    it "is valid with the maximum expiration year" do
      credit_card = CreditCard.new(
        card_number: "4111 1111 1111 1111",
        expiration_month: 12,
        expiration_year: Date.today.year + 50
      )
      expect(credit_card).to be_valid
    end

    it "is invalid without a card_number" do
      credit_card = CreditCard.new(
        card_number: nil,
        expiration_month: 12,
        expiration_year: Date.today.year + 1
      )
      expect(credit_card).to_not be_valid
    end

    it "is invalid without an expiration_month" do
      credit_card = CreditCard.new(
        card_number: "4111 1111 1111 1111",
        expiration_month: nil,
        expiration_year: Date.today.year + 1
      )
      expect(credit_card).to_not be_valid
    end
  end
end