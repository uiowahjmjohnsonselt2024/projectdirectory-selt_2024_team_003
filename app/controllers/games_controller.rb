class GamesController < ApplicationController
  
  # Retrieves and assigns to @games all games associated with the current user.
  def index
    @games = current_user.games
  end

  # Creates a new game and associates the current user with it.
  # If the game is successfully created, redirect to the grid page.
  # If the game is not successfully created, redirect back to the games page
  # with a flash warning.
  def create
    @game = Game.new(game_params) # create new game(name, code)
    GameUser.create(game: @game, user: current_user)
    if @game.save
      flash[:notice] = "Game was successfully created."
      session[:game_code] = @game.code
      # go to the grid page associated with this game
      redirect_to grid_path
    else
      flash[:alert] = "Failed to create game"
      # add flash warning
      redirect_to games_path
    end
  end

  
  def join
    # Find the game by the provided code (converted to uppercase for consistency)
    @game = Game.find_by(code: params[:code].upcase)

    if @game.nil?
      # Game does not exist
      flash[:alert] = "The game with code #{params[:code]} does not exist."
      redirect_to games_path
    else
      # Game exists, check if the user has already joined
      @game_user = GameUser.find_by(user: current_user, game: @game)
      session[:game_code] = @game.code

      if @game_user
        # User has already joined the game
        flash[:alert] = "You have already joined this game."
        redirect_to grid_path
      else
        # User has not joined the game, so create a new GameUser entry
        GameUser.create(user: current_user, game: @game)
        flash[:notice] = "Successfully joined the game!"
        redirect_to grid_path
      end
    end
  end

  def index
    @games = current_user.games
  end

  def win
    @game = Game.find_by(code: params[:game_id])
    @game_code = params[:game_id]
  end

  def end
    @game = Game.find_by(code: params[:game_code])
    @game.destroy
    redirect_to games_path, notice: 'Game has ended. Thank you for playing!'
  end
  

  private

  def game_params
    params.require(:game).permit(:name)
  end

end
