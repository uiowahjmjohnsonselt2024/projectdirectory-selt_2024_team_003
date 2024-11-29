class InteractionsController < ApplicationController
  def show
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)
    @player = current_user
  end

  def attack
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)
    @player = current_user
    @game_id = params[:game_id]

    player_damage, player_critical = calculate_attack_damage(@player, @enemy)
    @enemy.update(health: @enemy.health - player_damage)

    message = if player_critical
                "Critical Hit! You dealt #{player_damage} damage to the enemy!"
              else
                "You attacked the enemy! Enemy health: #{[@enemy.health, 0].max}"
              end

    if @enemy.health <= 0
      @enemy.update(health: 0)
      experience_gain = @enemy.level * 50
      @player.update(experience: @player.experience + experience_gain)
      level_up_if_needed(@player)
      message += " You defeated the enemy and gained #{experience_gain} XP!"
      if @enemy.x_position == 5 && @enemy.y_position == 5
        render json: { success: true, win: true, message: message } and return
      end
    else
      enemy_damage, enemy_critical = calculate_attack_damage(@enemy, @player)
      @game_user.update(health: @game_user.health - enemy_damage)

      message += if enemy_critical
                   " Critical Hit! The enemy dealt #{enemy_damage} damage to you!"
                 else
                   " The enemy attacked you and dealt #{enemy_damage} damage."
                 end
    end

    player_defeated = false
    if @game_user.health <= 0
      @game_user.update(health: @player.health)
      @game_user.update(x_position: 0, y_position: 0)
      message += " You have been defeated and sent back to the starting position!"
      player_defeated = true
    end

    render json: {
      success: true,
      message: message,
      enemy_health: @enemy.health,
      enemy_max_health: @enemy.max_health,
      player_health: @game_user.health,
      max_player_health: @player.health,
      player_defeated: player_defeated
    }
  end

  def magic_attack
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)
    @player = current_user
    @game_id = params[:game_id]

    if @game_user.use_mana(20)
      player_damage, player_critical = calculate_magic_damage(@player, @enemy)
      @enemy.update(health: @enemy.health - player_damage)

      message = if player_critical
                  "Critical Hit! You dealt #{player_damage} damage to the enemy!"
                else
                  "You attacked the enemy! Damage dealt: #{player_damage}"
                end

      if @enemy.health <= 0
        @enemy.update(health: 0)
        experience_gain = @enemy.level * 50
        @player.update(experience: @player.experience + experience_gain)
        level_up_if_needed(@player)
        message += " You defeated the enemy and gained #{experience_gain} XP!"
        if @enemy.x_position == 5 && @enemy.y_position == 5
          render json: { success: true, win: true, message: message } and return
        end
      else
        enemy_damage, enemy_critical = calculate_magic_damage(@enemy, @player)
        @game_user.update(health: @game_user.health - enemy_damage)

        message += if enemy_critical
                     " Critical Hit! The enemy dealt #{enemy_damage} damage to you!"
                   else
                     " The enemy attacked you and dealt #{enemy_damage} damage."
                   end
      end

      player_defeated = false
      if @game_user.health <= 0
        @game_user.update(health: @player.health)
        @game_user.update(x_position: 0, y_position: 0)
        message += " You have been defeated and sent back to the starting position!"
        player_defeated = true
      end

      render json: {
        success: true,
        message: message,
        enemy_health: @enemy.health,
        enemy_max_health: @enemy.max_health,
        player_health: @game_user.health,
        max_player_health: @player.health,
        player_defeated: player_defeated,
        player_mana: @game_user.mana,
        max_mana: @player.mana,
      }
    else
      render json: { success: false, message: "Not enough mana!" }
    end
  end

  def magic_heal
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)
    @player = current_user
    @game_id = params[:game_id]
    message = ""

    if @game_user.use_mana(20)
      healing = (@game_user.user.special_attack * 0.5).to_i
      @game_user.update(health: [@game_user.health + healing, @game_user.user.health].min)
      message += "Magic Heal restored #{healing} health!"
      enemy_damage, enemy_critical = calculate_attack_damage(@enemy, @player)
      @game_user.update(health: @game_user.health - enemy_damage)

      message += if enemy_critical
                   " Critical Hit! The enemy dealt #{enemy_damage} damage to you!"
                 else
                   " The enemy attacked you and dealt #{enemy_damage} damage."
                 end

      player_defeated = false
      if @game_user.health <= 0
        @game_user.update(health: @player.health)
        @game_user.update(x_position: 0, y_position: 0)
        message += " You have been defeated and sent back to the starting position!"
        player_defeated = true
      end

      render json: {
        success: true,
        message: message,
        enemy_health: @enemy.health,
        enemy_max_health: @enemy.max_health,
        player_health: @game_user.health,
        max_player_health: @player.health,
        player_mana: @game_user.mana,
        max_mana: @player.mana,
        player_defeated: player_defeated
      }
    else
      render json: { success: false, message: "Not enough mana!" }
    end
  end

  def calculate_attack_damage(attacker, defender)
    base_damage = [attacker.attack - (defender.defense / 2), 1].max
    critical_hit = rand(0..200) < attacker.iq
    damage = critical_hit ? base_damage * 2 : base_damage
    [damage, critical_hit]
  end

  def calculate_magic_damage(attacker, defender)
    base_damage = [attacker.special_attack - (defender.special_defense / 2), 1].max
    critical_hit = rand(0..200) < attacker.iq
    damage = critical_hit ? base_damage * 2 : base_damage
    [damage, critical_hit]
  end

  def level_up_if_needed(player)
    xp_threshold = player.level * 100
    if player.experience >= xp_threshold
      player.level_up
    end
  end
end
