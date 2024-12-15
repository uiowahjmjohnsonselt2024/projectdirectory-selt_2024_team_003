class InteractionsController < ApplicationController
  def show
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)
    @player = current_user.current_skin # Use current_skin for player stats
    @weapons = current_user.weapons
    @consumables = current_user.consumables

    case current_user.archetype
    when 'Attacker'
      @image = 'attack.png'
    when 'Defender'
      @image = 'defense.png'
    when 'Healer'
      @image = 'balanced.png'
    else
      @image = 'balanced.png'
    end

    other_players = @game.game_users.where.not(user: current_user)
    @players_in_same_pos = other_players.select do |other_player|
      other_player.x_position == @game_user.x_position && other_player.y_position == @game_user.y_position
    end
  end

  # Action to set a weapon as the current weapon
  def set_current_weapon
    weapon = current_user.weapons.find(params[:id]) # Find the weapon by ID
    weapon.set_as_current_weapon # Mark it as the current weapon for the user

    # Respond with success
    render json: { success: true }
  rescue ActiveRecord::RecordNotFound
    # If the weapon is not found, return an error response
    render json: { success: false, message: 'Weapon not found' }, status: :not_found
  end

  def attack
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)
    @player = current_user.current_skin # Use current_skin for player stats
    @game_id = params[:game_id]

    # Retrieve the current weapon's multiplier
    weapon_name = current_user.weapons.find { |weapon| weapon.current }&.name || 'default'
    weapon_multiplier = get_weapon_multiplier(weapon_name)

    # Calculate damage with the weapon multiplier
    player_damage, player_critical = calculate_attack_damage(@player, @enemy)
    player_damage *= weapon_multiplier # Apply weapon multiplier

    @enemy.update(health: @enemy.health - player_damage)
    Rails.logger.debug("Enemy health: #{@enemy.health}")

    message = if player_critical
                "Critical Hit! You dealt #{player_damage} damage to the enemy!"
              else
                "You attacked the enemy with your #{weapon_name}! Damage dealt: #{player_damage}"
              end

    if @enemy.health <= 0
      current_user.update(shards: current_user.shards + @enemy.level * 10)
      @enemy.update(health: 0)
      experience_gain = @enemy.level * 50
      @player.update(experience: @player.experience + experience_gain)
      level_up_if_needed(@player)
      message += " You defeated the enemy and gained #{experience_gain} XP!"
      current_user.add_achievement("First Blood: The thrill of victory, the first taste of triumph.")

      if @enemy.x_position == 5 && @enemy.y_position == 5
        current_user.add_achievement("The Final Boss: Defeat the final boss and claim victory over the game.")
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
      @game_user.update(mana: @player.mana)
      @game_user.update(x_position: 0, y_position: 0)
      message += ' You have been defeated and sent back to the starting position!'
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

  def use_consumable
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)
    @player = current_user.current_skin # Use current_skin for player stats
    @game_id = params[:game_id]
    message = ''
    player_defeated = false

    if @game.nil?
      render json: { success: false, message: 'Game not found!' }, status: :not_found and return
    end

    @game_user = @game.game_users.find_by(user: current_user)
    if @game_user.nil?
      render json: { success: false, message: 'Game user not found!' }, status: :not_found and return
    end

    # Use current_user.consumables to find the consumable
    consumable = current_user.consumables.find_by(id: params[:consumable_id])
    Rails.logger.debug("Consumable: #{consumable.name}")
    if consumable.nil? || consumable.quantity < 1
      render json: { success: false, message: 'Consumable not found!' }, status: :not_found and return
    end

    # Process the consumable logic (e.g., healing)
    if consumable.name == 'Revive'
      max_health = current_user.current_skin.health
      @game_user.update(health: max_health)

      # Decrease consumable quantity
      consumable.decrement!(:quantity)
      if consumable.quantity.zero?
        consumable.destroy
      end
      render json: {
        success: true,
        message: "You used #{consumable.name}! Health restored to #{max_health}.",
        consumable_quantity: consumable.quantity,
        player_health: max_health,
        player_mana: @game_user.mana,
        enemy_health: @enemy.health,
        enemy_max_health: @enemy.max_health,
        max_player_health: @player.health,
        player_defeated: player_defeated
      }
    elsif consumable.name == 'Acid Potion'
      @enemy.update(health: @enemy.health - 100)

      # Decrease consumable quantity
      consumable.decrement!(:quantity)
      if consumable.quantity.zero?
        consumable.destroy
      end
      if @enemy.health <= 0
        current_user.update(shards: current_user.shards + @enemy.level * 10)
        @enemy.update(health: 0)
        experience_gain = @enemy.level * 50
        @player.update(experience: @player.experience + experience_gain)
        level_up_if_needed(@player)
        message += " You defeated the enemy and gained #{experience_gain} XP!"
        current_user.add_achievement("First Blood: The thrill of victory, the first taste of triumph.")

        if @enemy.x_position == 5 && @enemy.y_position == 5
          current_user.add_achievement("The Final Boss: Defeat the final boss and claim victory over the game.")
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

      if @game_user.health <= 0
        @game_user.update(health: @player.health)
        @game_user.update(mana: @player.mana)
        @game_user.update(x_position: 0, y_position: 0)
        message += ' You have been defeated and sent back to the starting position!'
        player_defeated = true
      end

      render json: {
        success: true,
        message: message,
        consumable_quantity: consumable.quantity,
        player_health: @game_user.health,
        player_mana: @game_user.health,
        enemy_health: @enemy.health,
        enemy_max_health: @enemy.max_health,
        max_player_health: @player.health,
        player_defeated: player_defeated
      }
    elsif consumable.name == 'Mana Refill'
      max_mana = current_user.current_skin.mana
      @game_user.update(mana: max_mana)

      # Decrease consumable quantity
      consumable.decrement!(:quantity)
      if consumable.quantity.zero?
        consumable.destroy
      end
      render json: {
        success: true,
        message: "You used #{consumable.name}! Mana restored to #{max_mana}.",
        consumable_quantity: consumable.quantity,
        player_health: @game_user.health,
        player_mana: max_mana,
        enemy_health: @enemy.health,
        enemy_max_health: @enemy.max_health,
        max_player_health: @player.health,
        player_defeated: player_defeated
      }
    elsif consumable.name == 'Health Potion'
      @game_user.update(health: @game_user.health + 100)

      # Decrease consumable quantity
      consumable.decrement!(:quantity)
      if consumable.quantity.zero?
        consumable.destroy
      end
      render json: {
        success: true,
        message: "You used #{consumable.name}! Health restored to #{@game_user.health}.",
        consumable_quantity: consumable.quantity,
        player_health: @game_user.health,
        player_mana: @game_user.mana,
        enemy_health: @enemy.health,
        enemy_max_health: @enemy.max_health,
        max_player_health: @player.health,
        player_defeated: player_defeated
      }
    else
      render json: { success: false, message: 'Consumable has no effect!' }
    end
  end

  def magic_attack
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)
    @player = current_user.current_skin # Use current_skin for player stats
    @game_id = params[:game_id]
    message = ''

    case current_user.current_skin.archetype
    when 'Attacker'
      if @game_user.use_mana(20)
        if rand(1..100) <= 10
          @enemy.health = 0
          message = 'Coin Flip hit!'
        else
          message = 'Coin Flip missed!'
        end
      else
        render json: { success: false, message: 'Not enough mana!' } and return
      end
    when 'Defender'
      if @game_user.use_mana(20)
        player_damage, player_critical = calculate_magic_damage(@player, @enemy)
        @enemy.update(health: @enemy.health - player_damage)
        message = if player_critical
                    "Critical Hit! You dealt #{player_damage} damage to the enemy!"
                  else
                    "You attacked the enemy! Damage dealt: #{player_damage}"
                  end
      else
        render json: { success: false, message: 'Not enough mana!' } and return
      end
    when 'Healer'
      if @game_user.use_mana(20)
        healing = (@player.special_attack).to_i
        @game_user.update(health: [@game_user.health + healing, @game_user.user.health].min)
        message += "Magic Heal restored #{healing} health!"
      else
        render json: { success: false, message: 'Not enough mana!' } and return
      end
    else
      if @game_user.use_mana(20)
        healing = (@player.special_attack * 0.5).to_i
        @game_user.update(health: [@game_user.health + healing, @game_user.user.health].min)
        message += "Magic Heal restored #{healing} health!"
      else
        render json: { success: false, message: 'Not enough mana!' } and return
      end
    end

    if @enemy.health <= 0
      current_user.update(shards: current_user.shards + @enemy.level * 10)
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
      @game_user.update(mana: @player.mana)
      @game_user.update(x_position: 0, y_position: 0)
      message += ' You have been defeated and sent back to the starting position!'
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
      max_mana: @player.mana
    }
  end

  def magic_heal
    @game = Game.find_by(code: params[:game_id])
    @game_user = @game.game_users.find_by(user: current_user)
    @enemy = @game.enemies.find_by(x_position: @game_user.x_position, y_position: @game_user.y_position)
    @player = current_user.current_skin # Use current_skin for player stats
    @game_id = params[:game_id]
    message = ''

    if @game_user.use_mana(20)
      healing = (@player.special_attack * 0.5).to_i
      @game_user.update(health: [@game_user.health + healing, @player.health].min)
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
        message += ' You have been defeated and sent back to the starting position!'
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
      render json: { success: false, message: 'Not enough mana!' }
    end
  end

  def calculate_attack_damage(attacker, defender)
    base_damage = [attacker.attack - (defender.defense / 2), 1].max
    critical_hit = rand(0..200) < attacker.iq
    damage = critical_hit ? base_damage * 2 : base_damage
    [damage, critical_hit]
  end

  def get_weapon_multiplier(weapon_name)
    # Define the multipliers for each weapon
    # ["Sword", "Flame Sword", "Bow and Arrow", "Shotgun", "Sniper"]
    weapon_multipliers = {
      'knife' => 1,
      'sword' => 2,
      'flame sword' => 4,
      'bow and arrow' => 8,
      'shotgun' => 16,
      'sniper' => 32
    }

    # Return the multiplier for the weapon, default to 1 if weapon is not found
    weapon_multipliers[weapon_name.downcase] || 1.0
  end

  def calculate_magic_damage(attacker, defender)
    base_damage = [attacker.special_attack - (defender.special_defense / 2), 1].max
    base_damage = [(attacker.special_attack * 2) - (defender.special_defense / 2), 1].max
    critical_hit = rand(0..200) < attacker.iq
    damage = critical_hit ? base_damage * 2 : base_damage
    [damage, critical_hit]
  end

  def level_up_if_needed(player)
    xp_threshold = player.level * 100
    return unless player.experience >= xp_threshold

    player.level_up
  end
end
