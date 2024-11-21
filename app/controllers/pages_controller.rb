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
  def grid
    @user_name = current_user.username
    @profile_picture_url = "/path/to/profile.jpg"
    @stats = [
      { name: "Stat 1", value: 100 },
      { name: "Stat 2", value: 200 },
      { name: "Stat 3", value: 300 }
    ]
    # Find all players in the current game
    @players = Game.find_by(code: session[:game_code])&.game_users&.reject { |player| player.user.username == @user_name } || []
  end
end
