class Move < ActiveRecord::Base
  has_many :user_moves, dependent: :destroy
  has_many :users, through: :user_moves

  def execute(user:, target: nil, game_user: nil)
    case name
    when "Heal"
      game_user.update(health: [game_user.health + user.special_attack, user.health].min)
    when "Power Strike"
      target.update(health: [target.health - user.special_attack, 0].max)
      message = "Power Strike did "
    when "Coin Flip"
      if rand(1..100) <= 10
        target.update(health: [target.health - damage, 0].max)
        message = "Coin Flip hit!"
      else
        message = "Coin Flip missed!"
      end
    when "Basic Attack"
      target.update(health: [target.health - 1, 0].max)
    end
    message
  end
end
