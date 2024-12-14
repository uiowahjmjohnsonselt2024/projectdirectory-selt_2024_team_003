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
        arena[:players][1] = { id: 1, health: 100, turn: true }
        message = "Player 1 has joined the battle!"
      elsif arena[:players][2].nil?
        arena[:players][2] = { id: 2, health: 100, turn: false }
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
    opponent = player == 1 ? 2 : 1

    if arena[:players][player][:turn]
      damage = rand(10..30)
      arena[:players][opponent][:health] -= damage

      # Switch turns
      arena[:players][player][:turn] = false
      arena[:players][opponent][:turn] = true
      arena[:current_turn] = opponent

      # Check for game over condition
      if arena[:players][opponent][:health] <= 0
        broadcast_player_data("Player #{opponent} has been defeated!", current_turn: nil)
      else
        broadcast_player_data("Player #{player} attacked Player #{opponent} for #{damage} damage.")
      end
    else
      broadcast_player_data("It's not your turn, Player #{player}!")
    end
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
