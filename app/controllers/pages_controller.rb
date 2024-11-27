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
  before_action :set_game_user, only: [:move]

  def grid
    @user_name = current_user.username
    @profile_picture_url = "/path/to/profile.jpg"
    @stats = [
      { name: "Stat 1", value: 100 },
      { name: "Stat 2", value: 200 },
      { name: "Stat 3", value: 300 }
    ]
    @players = Game.find_by(code: session[:game_code])&.game_users&.reject { |player| player.user.username == @user_name } || []

    # Current player's position
    @current_game_user = current_user.game_users.find_by(game_id: session[:game_id])
  end

  # Handle movement
  def move
    new_x = params[:x_position].to_i
    new_y = params[:y_position].to_i

    if @game_user.move_to(new_x, new_y)
      render json: { success: true, position: { x: @game_user.x_position, y: @game_user.y_position } }
    else
      render json: { success: false, errors: @game_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_game_user
    @game_user = current_user.game_users.find_by(game_id: session[:game_id])
    unless @game_user
      render json: { success: false, errors: ["Player not found in this game"] }, status: :unprocessable_entity
    end
  end
end
