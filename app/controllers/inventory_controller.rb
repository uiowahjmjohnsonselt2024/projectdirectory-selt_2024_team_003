class InventoryController < ApplicationController
  before_action :authenticate_user! # Ensure the user is logged in

  # Action to add a new skin to the inventory
  def add
    image_data = params[:image_data]

    begin
      decoded_image = Base64.decode64(image_data)
      raise ArgumentError if decoded_image.blank? || !decoded_image.valid_encoding?

      skin = current_user.skins.build
      skin.image.attach(
        io: StringIO.new(decoded_image),
        filename: "generated_skin_#{Time.now.to_i}.png",
        content_type: 'image/png'
      )

      if skin.save
        redirect_to store_path
      else
        redirect_to store_path
      end
    rescue ArgumentError
      # Handle invalid Base64 data
      redirect_to store_path, alert: 'Invalid image data.'
    end
  end

  # Action to list all skins in the user's inventory
  def index
    # Fetch all skins associated with the current user
    @skins = current_user.skins
  end

  # Action to set a skin as the current skin
  def set_current
    skin = current_user.skins.find(params[:id]) # Ensure the skin belongs to the logged-in user
    current_user.skins.update_all(current: false) # Reset all current skins
    skin.update(current: true) # Set the selected skin as current

    redirect_to inventory_index_path
  rescue ActiveRecord::RecordNotFound
    redirect_to inventory_index_path
  end

  # Action to delete a skin
  def destroy
    skin = current_user.skins.find(params[:id]) # Ensure the skin belongs to the logged-in user
    if skin.destroy
      redirect_to inventory_index_path
    else
      redirect_to inventory_index_path
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to inventory_index_path
  end
end
