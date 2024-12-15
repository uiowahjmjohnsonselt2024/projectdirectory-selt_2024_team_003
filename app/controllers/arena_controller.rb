class ArenaController < ApplicationController
  def index
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)
    @player = current_user.current_skin
    @weapons = current_user.weapons
    #@consumables = current_user.consumables
    @user = current_user

    case current_user.archetype
    when 'Arcane Strategist'
      @image = 'attack.png'
    when 'Iron Guardian'
      @image = 'defense.png'
    when 'Omni Knight'
      @image = 'balanced.png'
    else
      @image = 'balanced.png'
    end
  end
end
