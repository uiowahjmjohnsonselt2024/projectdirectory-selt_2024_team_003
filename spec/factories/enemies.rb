FactoryBot.define do
  factory :enemy do
    name { "Enemy #{rand(1000)}" }
    level { 1 }
    health { 320 }
    attack { 22 }
    defense { 12 }
    iq { 6 }
    max_health { 320 }
    x_position { 0 }
    y_position { 0 }
    game
  end
end