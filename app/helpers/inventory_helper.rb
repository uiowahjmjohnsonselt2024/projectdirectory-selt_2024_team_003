module InventoryHelper
  # Maps a weapon name to its corresponding image filename used in the store.
  # Adjust the filenames as they appear in your app/assets/images folder.
  def weapon_image_filename(weapon_name)
    case weapon_name
    when "Sword"
      "sword.gif"
    when "Flame Sword"
      "flameSword.gif"
    when "Bow and Arrow"
      "bowAndArrow.gif"
    when "Shotgun"
      "shotgun.gif"
    when "Sniper"
      "sniper.gif"
    else
      "default_weapon.gif" # A fallback image if no match is found
    end
  end
end
