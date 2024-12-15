require 'rails_helper'

RSpec.describe "credit_cards/show.html.erb", type: :view do
  before do
    # Create a mock @credit_card instance with dummy attributes
    assign(:credit_card, CreditCard.new(
      card_type: "Visa",
      last4: "1234",
      expiration_month: 12,
      expiration_year: 2030
    ))
  end

  it "displays the page title" do
    render
    expect(rendered).to have_selector("h1.page-title", text: "Your Credit Card")
  end

  it "displays the credit card information" do
    render
    expect(rendered).to have_selector("p", text: "Card Type: Visa")
    expect(rendered).to have_selector("p", text: "Card Number: **** **** **** 1234")
    expect(rendered).to have_selector("p", text: "Expiration Date: 12/2030")
  end

  it "displays the Edit Card button" do
    render
    expect(rendered).to have_link("Edit Card", href: edit_credit_card_path, class: "button-link edit-card")
  end

  it "displays the Back button" do
    render
    expect(rendered).to have_link("Back", href: games_path, class: "button-link back-button")
  end
end