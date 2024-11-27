class InteractionsController < ApplicationController
  def show
    # Fetch the current position of the player from params
    @x_position = params[:x]
    @y_position = params[:y]

    # Initialize enemy health in session if it's not already set
    session[:enemy_health] ||= 300

    @enemy_health = session[:enemy_health]
    @attack_message = nil
  end

  def attack
    # Reduce enemy health by 50 for each attack
    session[:enemy_health] -= 50

    # Check if enemy health reaches 0 or below
    if session[:enemy_health] <= 0
      session[:enemy_health] = 0
      @attack_message = "You win!"
    else
      @attack_message = "You attacked the enemy! Enemy health: #{session[:enemy_health]}"
    end

    # Render the updated attack message
    render json: { success: true, message: @attack_message, health: session[:enemy_health] }
  end
end
