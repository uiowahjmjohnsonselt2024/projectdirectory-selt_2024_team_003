FactoryBot.define do
  factory :game_user do
    association :user # This assumes you have a User factory
    association :game # This assumes you have a Game factory
    x_position { 0 }  # Default starting position on the x-axis
    y_position { 0 }  # Default starting position on the y-axis
  end
end
