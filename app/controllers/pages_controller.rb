class PagesController < ApplicationController
  # app/controllers/pages_controller.rb
  
  # Grid page action.
  #
  # This action populates the grid page with data. It assigns the following
  # instance variables:
  #
  # * `@user_name`: The current user's username.
  # * `@players`: An array of players in the current game, excluding the current
  #   user.
  before_action :set_game_user

  def grid
    @user_name = current_user.username
    @profile_picture_url = "/path/to/profile.jpg"

    # Pull stats from the current skin instead of the user
    current_skin = current_user.current_skin
    @stats = [
      { name: "Archetype", value: current_skin&.archetype },
      { name: "Attack", value: current_skin&.attack },
      { name: "Special Attack", value: current_skin&.special_attack },
      { name: "Defense", value: current_skin&.defense },
      { name: "Special Defense", value: current_skin&.special_defense },
      { name: "IQ", value: current_skin&.iq }
    ]
    @players = Game.find_by(code: session[:game_code])&.game_users&.reject { |player| player.user.username == @user_name } || []
    @game = Game.find_by(code: session[:game_code])

    current_game = Game.find_by(code: session[:game_code])
    @current_game_user = current_user.game_users.find_by(game_id: current_game&.id)
    @move_path = move_pages_path
    @player = current_user

    # Update health, mana, and stats to use current skin
    @current_health = @current_game_user.health
    @max_health = current_skin&.health || 0
    @current_mana = @current_game_user.mana
    @max_mana = current_skin&.mana || 0

    @level = current_skin&.level || 1
    @current_experience = current_skin&.experience || 0
    @experience_for_next_level = 100 * @level # Example: Next level requires 100 * current level experience points
    @experience_percentage = (@current_experience.to_f / @experience_for_next_level * 100).round(2)
    # Store current position in session to persist between pages
    session[:current_position] = { x: @current_game_user.x_position, y: @current_game_user.y_position }
    @adjacent_tiles = calculate_adjacent_tiles(@current_game_user.x_position, @current_game_user.y_position)

    # Check if position is passed back from the casino page
    if params[:x].present? && params[:y].present?
      # Update the player's position
      new_x = params[:x].to_i
      new_y = params[:y].to_i

      # Send a request to the move API to update the player's position
      move_pages_path(x_position: new_x, y_position: new_y)
    end
  end

  # Handle movement
  def move
    new_x = params[:x_position].to_i
    new_y = params[:y_position].to_i

    if @game_user.move_to(new_x, new_y)
      render json: { success: true, message: 'Move successful', x: new_x, y: new_y }, status: :ok
    else
      render json: { success: false, error: "You can't move to this square" }, status: :unprocessable_entity
    end
  end

  def check_shards
    cost = params[:cost].to_i
    if current_user.shards >= cost
      render json: { success: true }
    else
      render json: { success: false, message: 'Insufficient shards' }
    end
  end

  # Force move action
  def force_move
    new_x = params[:x_position].to_i
    new_y = params[:y_position].to_i

    # Deduct 1 shard for the forced move
    if current_user.shards >= 10
      current_user.update(shards: current_user.shards - 10)
      @game_user.update(x_position: new_x, y_position: new_y)
      render json: { success: true, message: 'Force move successful', x: new_x, y: new_y }, status: :ok
    else
      render json: { success: false, error: 'Insufficient shards' }, status: :unprocessable_entity
    end
  end

  private

  def set_game_user
    current_game = Game.find_by(code: session[:game_code])
    @game_user = current_user.game_users.find_by(game_id: current_game&.id)
    return if @game_user

    render json: { success: false, errors: ['Player not found in this game'] }, status: :unprocessable_entity
  end

  def calculate_adjacent_tiles(x, y)
    [
      { x: x, y: y }, # Current tile
      { x: x - 1, y: y }, # Left
      { x: x + 1, y: y }, # Right
      { x: x, y: y - 1 }, # Up
      { x: x, y: y + 1 }, # Down
      { x: x - 1, y: y - 1 }, # Top-left diagonal
      { x: x - 1, y: y + 1 }, # Bottom-left diagonal
      { x: x + 1, y: y - 1 }, # Top-right diagonal
      { x: x + 1, y: y + 1 } # Bottom-right diagonal
    ].select do |tile|
      tile[:x] >= 0 && tile[:y] >= 0 # Ensure valid grid coordinates
    end
  end
end
