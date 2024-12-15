# spec/factories/skins.rb
FactoryBot.define do
  factory :skin do
    user
    archetype { "Attacker" } # Replace with a valid default archetype for your app

    after(:build) do |skin|
      skin.image.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
        filename: 'test_image.png',
        content_type: 'image/png'
      )
    end
  end
end
