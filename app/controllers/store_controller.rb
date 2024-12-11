class StoreController < ApplicationController
  before_action :authenticate_user!
  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Purchase Shards (already implemented)
  def purchase_shards
    if true # Placeholder for credit card check
      shard_count = params[:shard_count].to_i

      # Update user's shard count
      current_user.shards += shard_count
      if current_user.save
        render json: { success: true, message: "#{shard_count} shards purchased successfully!", shards: current_user.shards }
      else
        render json: { success: false, message: "Failed to update shards." }, status: :unprocessable_entity
      end
    else
      render json: { success: false, message: "Payment method not setup." }, status: :payment_required
    end
  end

  # Purchase an item with shards (new action)
  def purchase_item
    # Get item details from the frontend
    item_type = params[:itemType]
    item_price = params[:itemPrice].to_i

    # Check if the user has enough shards
    if current_user.shards >= item_price
      # Deduct shards for the purchase
      current_user.shards -= item_price
      if current_user.save
        # Item purchased successfully
        render json: { success: true, message: "#{item_type} purchased successfully!", shards: current_user.shards }
      else
        render json: { success: false, message: "Failed to update shards." }, status: :unprocessable_entity
      end
    else
      # Insufficient funds
      render json: { success: false, message: "Insufficient funds for #{item_type}." }, status: :unprocessable_entity
    end
  end
end
