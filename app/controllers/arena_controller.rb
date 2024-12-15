class ArenaController < ApplicationController
  def index
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)
    @player = current_user.current_skin
    @weapons = current_user.weapons
    @consumables = current_user.consumables
    @user = current_user


    case @player.archetype
    when 'Attacker'
      @image = 'attack.png'
    when 'Defender'
      @image = 'defense.png'
    when 'Healer'
      @image = 'balanced.png'
    else
      @image = 'balanced.png'
    end
  end
end
