class ArenaChannel < ApplicationCable::Channel
  @@arenas = {} # Class-level variable to store arena data for all instances

  def subscribed
    @arena_id = params[:arena_id]

    # Initialize the players hash for this arena if it doesn't already exist
    @@arenas[@arena_id] ||= { players: {}, current_turn: 1 }

    # Broadcast the current game state to all players
    broadcast_player_data

    # Stream from the correct arena channel
    stream_from "arena_#{@arena_id}_channel"
  end

  def assign_player(data)
    arena = @@arenas[@arena_id]
    player_id = data['player_id'].to_i

    if arena[:players][player_id].nil?
      if arena[:players][1].nil?
        arena[:players][1] = {
          id: data['player_id'].to_i,
          username: data['user_name'],
          health: data['health'].to_i,
          max_health: data['max_health'].to_i,
          mana: data['mana'].to_i,
          max_mana: data['max_mana'].to_i,
          attack: data['attack'].to_i,
          special_attack: data['special_attack'].to_i,
          defense: data['defense'].to_i,
          special_defense: data['special_defense'].to_i,
          iq: data['iq'].to_i,
          level: data['level'].to_i,
          archetype: data['archetype'],
          turn: false
        }
        message = "Player 1 has joined the battle!"
      elsif arena[:players][2].nil?
        arena[:players][2] = {
          id: data['player_id'].to_i,
          username: data['user_name'],
          health: data['health'].to_i,
          max_health: data['max_health'].to_i,
          mana: data['mana'].to_i,
          max_mana: data['max_mana'].to_i,
          attack: data['attack'].to_i,
          special_attack: data['special_attack'].to_i,
          defense: data['defense'].to_i,
          special_defense: data['special_defense'].to_i,
          iq: data['iq'].to_i,
          level: data['level'].to_i,
          archetype: data['archetype'],
          turn: true
        }
        message = "Player 2 has joined the battle!"
      else
        message = "Both players are already assigned."
      end
    else
      message = "You are already assigned to the game."
    end

    # Broadcast updated player data
    broadcast_player_data(message)
  end

  def attack(data)
    arena = @@arenas[@arena_id]
    player = data['player_id'].to_i

    current_player = arena[:players].values.find { |p| p[:id].to_i == player }
    puts current_player[:username]
    opponent = arena[:players].values.find { |p| p[:id].to_i != player }

    if current_player && current_player[:turn]
      player_damage, player_critical = calculate_attack_damage(current_player, opponent)
      opponent[:health] -= player_damage
      message = if player_critical
                  "Critical Hit! #{current_player[:username]} dealt #{player_damage} damage to #{opponent[:username]}!"
                else
                  "#{current_player[:username]} attacked #{opponent[:username]} for #{player_damage} damage."
                end

      # Switch turns
      current_player[:turn] = false
      opponent[:turn] = true
      arena[:current_turn] = opponent[:id]

      # Check for game over condition
      if opponent[:health] <= 0
        opponent[:health] = 0
        broadcast_player_data(message + "#{opponent[:username]} has been defeated!")
      else
        broadcast_player_data(message)
      end
    else
      broadcast_player_data("It's not your turn, #{current_player[:username]}!")
    end
  end

  def special_attack(data)
    arena = @@arenas[@arena_id]
    player = data['player_id'].to_i
    puts arena[:players]
    puts "|||||||||||||||||||||||||||||||||||||||||||||||"

    current_player = arena[:players].values.find { |p| p[:id].to_i == player }
    opponent = arena[:players].values.find { |p| p[:id].to_i != player }
    message = ''

    if current_player && current_player[:turn]
      if current_player[:mana] >= 20
        current_player[:turn] = false
        opponent[:turn] = true
        arena[:current_turn] = opponent[:id]
      end

      case current_player[:archetype]
      when 'Attacker'
        if current_player[:mana] >= 20
          current_player[:mana] -= 20
          if rand(1..100) <= 10
            opponent[:health] = 0
            message = "#{current_player[:username]} used Coin Flip and it hit!"
          else
            message = "#{current_player[:username]} used Coin Flip and it missed."
          end
        else
          message = "Not enough mana, #{current_player[:username]}!"
        end
      when 'Defender'
        if current_player[:mana] >= 20
          current_player[:mana] -= 20
          player_damage, player_critical = calculate_magic_damage(current_player, opponent)
          opponent[:health] -= player_damage
          message = if player_critical
                      "Critical Hit! #{current_player[:username]} dealt #{player_damage} damage to #{opponent[:username]}!"
                    else
                      "#{current_player[:username]} used their special move on #{opponent[:username]} for #{opponent[:username]} damage."
                    end
        else
          message = "Not enough mana, #{current_player[:username]}!"
        end
      when 'Healer'
        if current_player[:mana] >= 20
          current_player[:mana] -= 20
          old = current_player[:health]
          current_player[:health] =  [current_player[:health] + current_player[:special_attack], current_player[:max_health]].min
          message += "#{current_player[:username]} healed #{current_player[:health] - old} health."
        else
          message = "Not enough mana, #{current_player[:username]}!"
        end
      else
        if current_player[:mana] >= 20
          current_player[:mana] -= 20
          old = current_player[:health]
          current_player[:health] =  [current_player[:health] + current_player[:special_attack], current_player[:max_health]].min
          message += "#{current_player[:username]} healed #{current_player[:health] - old} health."
        else
          message = "Not enough mana, #{current_player[:username]}!"
        end
      end

      # Check for game over condition
      if opponent[:health] <= 0
        opponent[:health] = 0
        broadcast_player_data(message + " #{opponent[:username]} has been defeated!")
      else
        broadcast_player_data(message)
      end
    else
      broadcast_player_data("It's not your turn, #{current_player[:username]}!")
    end
  end

  def calculate_attack_damage(attacker, defender)
    base_damage = [attacker[:attack] - (defender[:defense] / 2), 1].max
    critical_hit = rand(0..200) < attacker[:iq]
    damage = critical_hit ? base_damage * 2 : base_damage
    [damage, critical_hit]
  end

  def calculate_magic_damage(attacker, defender)
    base_damage = [attacker[:special_attack] - (defender[:special_defense] / 2), 1].max
    critical_hit = rand(0..200) < attacker[:iq]
    damage = critical_hit ? base_damage * 2 : base_damage
    [damage, critical_hit]
  end

  def unsubscribed
    arena = @@arenas[@arena_id]
    arena[:players].delete(@player_id)
    broadcast_player_data("Player #{@player_id} has left the battle.")
  end

  private

  def broadcast_player_data(message = "Waiting for players...")
    arena = @@arenas[@arena_id]
    ActionCable.server.broadcast "arena_#{@arena_id}_channel", {
      message: message,
      players: arena[:players],
      current_turn: arena[:current_turn]
    }
  end
end
