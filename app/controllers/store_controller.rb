class StoreController < ApplicationController
  before_action :authenticate_user!
  helper_method :current_user

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Purchase Shards
  def purchase_shards
    if current_user.has_credit_card?
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
        # Define the item categories
        weapons_list = ["Sword", "Flame Sword", "Bow and Arrow", "Shotgun", "Sniper"]
        consumables_list = ["Health Potion", "Acid Potion", "Revive", "Mana Refill"]

        if weapons_list.include?(item_type)
          # Handle weapons
          if current_user.weapons.exists?(name: item_type)
            render json: { success: false, message: "You already own #{item_type}." }, status: :unprocessable_entity
            return
          end

          weapon = current_user.weapons.create(name: item_type)
          unless weapon.persisted?
            render json: { success: false, message: "Failed to add weapon to your inventory." }, status: :unprocessable_entity
            return
          end
        elsif consumables_list.include?(item_type)
          # Handle consumables
          consumable = current_user.consumables.find_or_initialize_by(name: item_type)
          Rails.logger.debug("Consumable: #{consumable.quantity}")
          if consumable.new_record?
            consumable.quantity = 1
          else
            consumable.increment_quantity
          end

          unless consumable.save
            render json: { success: false, message: "Failed to add consumable to your inventory." }, status: :unprocessable_entity
            return
          end
        elsif item_type == "AI Generated Avatar"
          # Handle AI Generated Avatar
          render json: { success: true, message: "AI Generated Avatar purchased successfully!", shards: current_user.shards }
          return
        else
          render json: { success: false, message: "Invalid item type." }, status: :unprocessable_entity
          return
        end

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
