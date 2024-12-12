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
    @profile_picture_url = '/path/to/profile.jpg'
    @stats = [
      { name: 'Archetype', value: current_user.archetype },
      { name: 'Attack', value: current_user.attack },
      { name: 'Special Attack', value: current_user.special_attack },
      { name: 'Defense', value: current_user.defense },
      { name: 'Special Defense', value: current_user.special_defense },
      { name: 'IQ', value: current_user.iq }
    ]
    @players = Game.find_by(code: session[:game_code])&.game_users&.reject do |player|
      player.user.username == @user_name
    end || []
    @game = Game.find_by(code: session[:game_code])

    current_game = Game.find_by(code: session[:game_code])
    @current_game_user = current_user.game_users.find_by(game_id: current_game&.id)
    @move_path = move_pages_path
    @player = current_user

    @current_health = @current_game_user.health
    @max_health = @player.health
    @current_mana = @current_game_user.mana
    @max_mana = @player.mana

    @level = @player.level || 1
    @current_experience = @player.experience || 0
    @experience_for_next_level = 100 * @level # Example: Next level requires 100 * current level experience points
    @experience_percentage = (@current_experience.to_f / @experience_for_next_level * 100).round(2)
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

  private

  def set_game_user
    current_game = Game.find_by(code: session[:game_code])
    @game_user = current_user.game_users.find_by(game_id: current_game&.id)
    return if @game_user

    render json: { success: false, errors: ['Player not found in this game'] }, status: :unprocessable_entity
  end
end
