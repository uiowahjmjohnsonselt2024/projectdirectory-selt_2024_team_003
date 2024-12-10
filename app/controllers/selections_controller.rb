class SelectionsController < ApplicationController
  before_action :authenticate_user! # Ensure the user is logged in

  def index
    # Render the initial character selection page
  end

  def update_archetype
    archetype = params[:archetype]

    # Set the user's archetype stats
    current_user.set_archetype_stats(archetype)

    # Add the initial skin to the user's inventory
    skin_image_path = select_skin_image(archetype)
    skin = current_user.skins.build
    skin.image.attach(
      io: File.open(Rails.root.join("app/assets/images/#{skin_image_path}")),
      filename: "#{archetype.downcase.gsub(' ', '_')}.png",
      content_type: "image/png"
    )
    skin.current = true # Mark as current skin

    if skin.save
      render json: { success: true }
    else
      render json: { success: false, error: "Failed to save skin: #{skin.errors.full_messages.join(', ')}" }
    end
  rescue => e
    render json: { success: false, error: e.message }
  end

  private

  # Map archetypes to skin image file paths
  def select_skin_image(archetype)
    case archetype
    when "Wizard"
      "attack.png"
    when "Titan"
      "defense.png"
    when "Knight"
      "balanced.png"
    else
      raise "Invalid archetype selected"
    end
  end
end
