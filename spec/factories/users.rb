FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" } # Ensures unique usernames
    sequence(:email) { |n| "user#{n}@example.com" } # Ensures unique emails
    password { "password" }
    health { 100 }
    attack { 10 }
    defense { 5 }
    iq { 1 }
    level { 1 }
    experience { 0 }
  end
end
