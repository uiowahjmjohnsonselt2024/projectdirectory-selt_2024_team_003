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
    puts "||||||||||||}}}}}}}}}}}}}}}}}}}}"
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

    if params[:search].present?
      @users = User.where("username LIKE ?", "%#{params[:search]}%").where.not(id: current_user.id)
    else
      @users = User.where.not(id: current_user.id)
    end
  end

  def add_friend
    friend = User.find(params[:friend_id])

    if current_user.friends.include?(friend)
      flash[:alert] = "#{friend.username} is already your friend."
    else
      current_user.friendships.create(friend: friend)
      flash[:notice] = "#{friend.username} has been added to your friends list!"
    end

    redirect_to games_path
  end
  
  def remove_friend
    friend = User.find(params[:friend_id])

    friendship = current_user.friendships.find_by(friend: friend)
    if friendship
      friendship.destroy
      flash[:notice] = "#{friend.username} has been removed from your friends list."
    else
      flash[:alert] = "#{friend.username} is not your friend."
    end

    redirect_to games_path
  end
  

  private

  def game_params
    params.require(:game).permit(:name)
  end

end
