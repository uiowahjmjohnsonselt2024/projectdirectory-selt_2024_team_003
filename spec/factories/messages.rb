FactoryBot.define do
  factory :message do
    content { 'Hello!' }
    association :user
    association :recipient, factory: :user
  end
end
