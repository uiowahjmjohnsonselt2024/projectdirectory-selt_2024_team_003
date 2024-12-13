FactoryBot.define do
  factory :credit_card do
    user { nil }
    last4 { "MyString" }
    expiration_month { 1 }
    expiration_year { 1 }
    card_type { "MyString" }
  end
end
