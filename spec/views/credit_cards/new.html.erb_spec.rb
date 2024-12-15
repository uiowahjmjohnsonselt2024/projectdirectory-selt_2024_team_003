require 'rails_helper'

RSpec.describe "credit_cards/new.html.erb", type: :view do
  before do
    # Create a mock @credit_card instance
    assign(:credit_card, CreditCard.new)
  end

  it "displays the form heading" do
    render
    expect(rendered).to have_selector("h1", text: "Add Credit Card")
  end

  it "displays the form for adding a credit card" do
    render
    expect(rendered).to have_selector("form[action='#{credit_card_path}'][method='post']")
  end

  it "displays a label and text field for card number" do
    render
    expect(rendered).to have_selector("label", text: "Card Number")
    expect(rendered).to have_selector("input.credit-card-input[type='text'][maxlength='19'][placeholder='Enter 16-digit card number']")
  end

  it "displays a label and password field for CVV" do
    render
    expect(rendered).to have_selector("label", text: "CVV")
    expect(rendered).to have_selector("input.cvv-input[type='password']")
  end

  it "displays a label and number field for expiration month" do
    render
    expect(rendered).to have_selector("label", text: "Expiration Month")
    expect(rendered).to have_selector("input[type='number'][name='credit_card[expiration_month]']")
  end

  it "displays a label and number field for expiration year" do
    render
    expect(rendered).to have_selector("label", text: "Expiration Year")
    expect(rendered).to have_selector("input[type='number'][name='credit_card[expiration_year]']")
  end

  it "displays a submit button and back link" do
    render
    expect(rendered).to have_link("Back", href: games_path)
    expect(rendered).to have_selector("input[type='submit'][value='Save Card']")
  end

  context "when there are validation errors" do
    before do
      credit_card = CreditCard.new
      credit_card.errors.add(:card_number, "is invalid")
      assign(:credit_card, credit_card)
    end

    it "displays an error message" do
      render
      expect(rendered).to have_selector("div.error")
      expect(rendered).to have_content("is invalid")
    end
  end
end