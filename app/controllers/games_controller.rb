class GamesController < ApplicationController
  def index
    @games = Game.all
    # Get current user username
  end

  def create
    @game = Game.new(game_params) # create new game(name, code)
    if @game.save
      puts "Game successfully created"
      # go to the grid page associated with this game
      redirect_to games_path
    else
      puts "Game unsuccessfully created"
      # add flash warning
      redirect_to games_path
    end
  end

  def join
    @game = Game.find_by(code: params[:code].upcase)

    if @game
      puts "Game successfully joined"
      # go to grid page associated with that game
      redirect_to games_path
    else
      puts "Game unsuccessfully joined"
      redirect_to games_path
    end
  end

  private

  def game_params
    params.require(:game).permit(:name)
  end

end
