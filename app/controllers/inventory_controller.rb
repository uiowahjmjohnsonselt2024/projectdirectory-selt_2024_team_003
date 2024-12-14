class InventoryController < ApplicationController
  before_action :authenticate_user! # Ensure the user is logged in

  # Action to list all items in the user's inventory
  def index
    @skins = current_user.skins
    @weapons = current_user.weapons
    @consumables = current_user.consumables
  end

  # Action to add a new skin to the inventory
  def add_skin
    image_data = params[:image_data]
    archetype = params[:archetype]

    begin
      decoded_image = Base64.decode64(image_data)
      raise ArgumentError if decoded_image.blank? || !decoded_image.valid_encoding?

      # Create a new skin with archetype and attach the image
      skin = current_user.skins.build(archetype: archetype)
      skin.image.attach(
        io: StringIO.new(decoded_image),
        filename: "generated_skin_#{Time.now.to_i}.png",
        content_type: 'image/png'
      )

      if skin.save
        redirect_to inventory_index_path
      else
        redirect_to store_path
      end
    rescue ArgumentError
      # Handle invalid Base64 data
      redirect_to store_path
    end
  end

  # Action to add a new weapon to the inventory
  def add_weapon
    name = params[:name]

    # Create the new weapon
    weapon = current_user.weapons.build(name: name)

    if weapon.save
      redirect_to inventory_index_path(tab: 'weapons'), notice: 'Weapon purchased and set as current!'
    else
      redirect_to store_path, alert: 'Failed to purchase weapon.'
    end
  end

  # Action to set a skin as the current skin
  def set_current_skin
    skin = current_user.skins.find(params[:id]) # Ensure the skin belongs to the logged-in user
    skin.set_as_current_skin # Call the model method
    redirect_to inventory_index_path
  rescue ActiveRecord::RecordNotFound
    redirect_to inventory_index_path, alert: "Skin not found"
  end

  # Action to set a weapon as the current weapon
  def set_current_weapon
    weapon = current_user.weapons.find(params[:id]) # Ensure the weapon belongs to the logged-in user
    weapon.set_as_current_weapon # Call the model method
    redirect_to inventory_index_path(tab: 'weapons')
  rescue ActiveRecord::RecordNotFound
    redirect_to inventory_index_path(tab: 'weapons'), alert: "Weapon not found"
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
    redirect_to inventory_index_path, alert: "Skin not found"
  end
end
