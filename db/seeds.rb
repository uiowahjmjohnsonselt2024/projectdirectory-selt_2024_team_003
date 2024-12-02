# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

moves = [
  { name: "Basic Attack", description: "A basic attack that deals damage.", mana_cost: 10, damage: 15 },
  { name: "Heal", description: "Restores a small amount of health.", mana_cost: 15, health_cost: 0 },
  { name: "Power Strike", description: "A powerful attack with high mana cost.", mana_cost: 25, damage: 30 },
  { name: "Team Heal", description: "Heals all team members.", mana_cost: 30, health_cost: 0 }
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