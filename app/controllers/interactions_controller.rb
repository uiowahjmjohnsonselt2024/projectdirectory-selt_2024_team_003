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

    enemy_def = @player.defense / 2
    player_attack_damage = [@player.attack - enemy_def, 1].max  # Ensure no negative damage

    # Decrease enemy health by the player's attack value
    @enemy.update(health: @enemy.health - player_attack_damage)

    # Check if the enemy's health is 0 or below
    if @enemy.health <= 0
      @enemy.update(health: 0)
      experience_gain = @enemy.level * 50
      @player.update(experience: @player.experience + experience_gain)
      level_up_if_needed(@player)
      message = "You defeated the enemy and gained #{experience_gain} XP!"
    else
      message = "You attacked the enemy! Enemy health: #{@enemy.health}"
    end

    player_def = @player.defense / 2
    enemy_attack_damage = [@enemy.attack - player_def, 1].max  # Ensure no negative damage

    # Decrease player health by the enemy's attack value
    @game_user.update(health: @game_user.health - enemy_attack_damage)

    # If the player's health reaches 0 or below, reset to starting position with max health
    if @game_user.health <= 0
      @game_user.update(health: @player.health)  # Reset to starting health
      @game_user.update(x_position: 0, y_position: 0)  # Reset position to (0,0)
      message += " You have been defeated and sent back to the starting position!"
    end

    # Calculate the current player health and max player health
    player_health = @game_user.health
    max_player_health = @player.health

    render json: {
      success: true,
      message: message,
      enemy_health: @enemy.health,
      enemy_max_health: @enemy.max_health,
      player_health: player_health,
      max_player_health: max_player_health
    }
  end

  def calculate_damage(attacker, defender)
    attack_value = attacker.attack
    defense_value = defender.defense
    damage = attack_value - (defense_value / 2)
    [damage, 1].max # Ensure damage is not negative
  end

  # Enemy's turn to attack
  def enemy_attack(enemy, game_user)
    damage = calculate_damage(enemy, game_user)
    game_user.update(health: game_user.health - damage)
  end

  def level_up_if_needed(player)
    xp_threshold = player.level * 100
    if player.experience >= xp_threshold
      player.level_up
    end
  end
end
