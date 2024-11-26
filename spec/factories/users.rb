FactoryBot.define do
  factory :user do
    username { "user#{rand(1000)}" }
    email { "user#{rand(1000)}@example.com" }
    password { "password" }
  end
end