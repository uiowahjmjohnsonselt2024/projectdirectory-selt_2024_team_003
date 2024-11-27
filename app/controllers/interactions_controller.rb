class InteractionsController < ApplicationController
  def show
    @game = Game.find_by(code: params[:game_id])  # Get the game by ID
    @game_user = @game.game_users.find_by(user: current_user)  # Find the GameUser for the current user
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)  # Find the enemy at the player's position
    @player = current_user  # Assuming you still want access to the player's overall stats
  end

  def attack
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)  # Find the GameUser for the current user
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)  # Find the enemy
    @player = current_user
    @game_id = params[:game_id]

    # Decrease enemy health by the player's attack value
    @enemy.update(health: @enemy.health - @player.attack)

    # Check if the enemy's health is 0 or below
    if @enemy.health <= 0
      @enemy.update(health: 0)
      message = "You win!"
    else
      message = "You attacked the enemy! Enemy health: #{@enemy.health}"
    end

    render json: { success: true, message: message, enemy_health: @enemy.health }
  end
end
