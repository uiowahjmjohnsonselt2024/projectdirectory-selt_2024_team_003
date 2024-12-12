class CasinoController < ApplicationController
  before_action :set_game_user

  def show
    @current_position = session[:current_position]
    @user_shards = current_user.shards
  end

  def place_bet
    bet_amount = params[:bet_amount].to_i
    user_bet = params[:user_bet] # Passed from the frontend ('red', 'black', 'green')
    winner = params[:winner] # The winner ('red', 'black', or 'green') passed from the frontend

    # Check if the user has enough shards to place the bet
    if bet_amount >= 0 && current_user.shards >= bet_amount
      # Deduct the bet amount from the user's shards
      if winner == "pending"
        current_user.shards -= bet_amount
      end

      if current_user.save
        # If winner is set, calculate win/loss after spin
        if winner != "pending"
          is_win = user_bet == winner
          if is_win
            winnings = bet_amount * 2
            current_user.shards += winnings
          end

          # Save updated shards
          if current_user.save
            result = is_win ? "You won! #{winnings} shards." : "You lost! The spin landed on #{winner}. Better luck next time."
            render json: { success: true, result: result, shards: current_user.shards, is_win: is_win }
          else
            render json: { success: false, message: 'Failed to update shards.' }, status: :unprocessable_entity
          end
        else

          render json: { success: true, message: 'Bet placed successfully.' }
        end
      else
        render json: { success: false, message: 'Failed to deduct shards.' }, status: :unprocessable_entity
      end
    else
      if winner == "pending"
        render json: { success: false, message: 'Insufficient shards or invalid bet amount.' }, status: :unprocessable_entity
      end
    end
  end

  private

  def set_game_user
    current_game = Game.find_by(code: session[:game_code])
    @game_user = current_user.game_users.find_by(game_id: current_game&.id)
    render json: { success: false, errors: ['Player not found in this game'] }, status: :unprocessable_entity unless @game_user
  end
end
