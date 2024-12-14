class StoreController < ApplicationController
  before_action :authenticate_user!
  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Purchase Shards
  def purchase_shards
    if true # Placeholder for credit card check
      shard_count = params[:shard_count].to_i

      current_user.shards += shard_count
      if current_user.save
        render json: { success: true, message: "#{shard_count} shards purchased successfully!",
                       shards: current_user.shards }
        NotificationMailer.purchase_notification(current_user, shard_count).deliver
      else
        render json: { success: false, message: 'Failed to update shards.' }, status: :unprocessable_entity
      end
    else
      render json: { success: false, message: 'Payment method not setup.' }, status: :payment_required
    end
  end

  # Purchase an item with shards
  def purchase_item
    item_type = params[:itemType]
    item_price = params[:itemPrice].to_i

    # Check if the user can afford the item
    if current_user.shards >= item_price
      current_user.shards -= item_price
      if current_user.save
        # Item purchased successfully. Now check if it's a weapon.
        # Define a list of weapons available for purchase. Update this array as needed.
        weapons_list = ["Sword", "Flame Sword", "Bow and Arrow", "Shotgun", "Sniper"]

        if weapons_list.include?(item_type)
          # Check if the weapon already exists in the user's inventory
          if current_user.weapons.exists?(name: item_type)
            render json: { success: false, message: "You already own #{item_type}." }, status: :unprocessable_entity
            return
          end

          # Add the weapon to the user's database
          weapon = current_user.weapons.create(name: item_type)
          unless weapon.persisted?
            # If weapon failed to save, return an error response
            render json: { success: false, message: "Failed to add weapon to your inventory." }, status: :unprocessable_entity
            return
          end
        end

        # If everything went well
        render json: { success: true, message: "#{item_type} purchased successfully!", shards: current_user.shards }
      else
        render json: { success: false, message: 'Failed to update shards.' }, status: :unprocessable_entity
      end
    else
      # Insufficient funds
      render json: { success: false, message: "Insufficient funds for #{item_type}." }, status: :unprocessable_entity
    end
  end
end
