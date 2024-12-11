moves = [
  { name: "Basic Attack", description: "Default attack", mana_cost: 0, damage: 0, health_cost: 0 },
  { name: "Heal", description: "Restores the user's health.", mana_cost: 30, health_cost: 30, damage: 0 },
  { name: "Power Strike", description: "The user bashes the enemy with their body.", mana_cost: 0, damage: 30, health_cost: 0 },
  { name: "Coin Flip", description: "An attack that insta-kills the enemy, with low probability", mana_cost: 30, damage: 0, health_cost: 0 },
]

moves.each do |move|
  Move.find_or_create_by!(name: move[:name]) do |m|
    m.description = move[:description]
    m.mana_cost = move[:mana_cost]
    m.damage = move[:damage]
    m.health_cost = move[:health_cost]
  end
end

puts "Default moves created!"