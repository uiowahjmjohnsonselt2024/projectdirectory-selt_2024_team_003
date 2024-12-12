FactoryBot.define do
  factory :game do
    name { 'Test Game' }
    code { SecureRandom.alphanumeric(4).upcase }
  end
end
