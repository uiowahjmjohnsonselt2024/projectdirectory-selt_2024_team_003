class Move < ActiveRecord::Base
  has_many :user_moves, dependent: :destroy
  has_many :users, through: :user_moves

  def execute(user:, target: nil, game_user: nil)
    # Logic for the move's effect
    case effect_type
    when "heal"
      user.update(health: [user.health + damage, user.max_health].min)
    when "team_heal"
      game_user.team_members.each do |ally|
        ally.update(health: [ally.health + damage, ally.max_health].min)
      end
    when "damage"
      target.update(health: [target.health - damage, 0].max)
      user.update(health: [user.health - health_cost, 0].max)
    when "special_damage"
      target.update(health: [target.health - (damage * 1.5).to_i, 0].max)
    end
  end
end
