FactoryBot.define do
  factory :skin do
    user
    archetype { "Attacker" }
    health { 100 }  # Default health value
    mana { 50 }     # Default mana value

    after(:build) do |skin|
      skin.image.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.png')),
        filename: 'test_image.png',
        content_type: 'image/png'
      )
    end
  end
end
