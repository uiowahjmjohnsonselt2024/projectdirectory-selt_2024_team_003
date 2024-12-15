class CasinoController < ApplicationController
  before_action :authenticate_user! # Ensure the user is logged in
  before_action :set_game_user

  def show
    @current_position = session[:current_position]
    @user_shards = current_user.shards
  end

  def place_bet
    bet_amount = params[:bet_amount].to_i
    user_bet = params[:user_bet] # Passed from the frontend ('red', 'black', 'green')
    winner = params[:winner] # The winner ('red', 'black', or 'green') passed from the frontend

    if bet_amount >= 250
      current_user.add_achievement('High Roller: The casino calls to you')
    end
    # Check if the user has enough shards to place the bet
    if bet_amount > 0 && current_user.shards >= bet_amount
      if winner == "pending"
        render json: { success: true, message: 'Bet placed successfully.' }
      else
        is_win = user_bet == winner
        winnings = is_win ? bet_amount * (winner == "green" ? 14 : 2) : 0
        current_user.shards += winnings - bet_amount

        # Save updated shards
        if current_user.save
          result = is_win ? "You won! #{winnings} shards." : "You lost! The spin landed on #{winner}. Better luck next time."
          render json: { success: true, result: result, shards: current_user.shards, is_win: is_win }
        else
          render json: { success: false, message: 'Failed to update shards.' }, status: :unprocessable_entity
        end
      end
    else
      render json: { success: false, message: 'Insufficient shards or invalid bet amount.' }, status: :unprocessable_entity
    end
  end

  private

  def set_game_user
    current_game = Game.find_by(code: session[:game_code])
    @game_user = current_user.game_users.find_by(game_id: current_game&.id)
    render json: { success: false, errors: ['Player not found in this game'] }, status: :unprocessable_entity unless @game_user
  end
end
