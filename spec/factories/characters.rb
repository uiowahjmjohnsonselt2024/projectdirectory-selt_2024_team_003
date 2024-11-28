FactoryBot.define do
  factory :character do
    name { "Test Character" }
    shards { 100 } # Default shards
    association :player # Links this character to a player
  end
end
