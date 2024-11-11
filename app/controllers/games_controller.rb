class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      puts "Game successfully created"
      redirect_to games_path
    else
      puts "Game unsuccessfully created"
      redirect_to games_path
    end
  end

  def join
    @game = Game.find_by(code: params[:code].upcase)

    if @game
      puts "Game successfully joined"
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
