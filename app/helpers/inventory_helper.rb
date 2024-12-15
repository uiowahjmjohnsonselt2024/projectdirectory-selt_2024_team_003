module InventoryHelper
  # Maps a weapon name to its corresponding image filename
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
    when "Knife"
      "knife.gif" # Add the Knife mapping
    else
      "default_weapon.gif" # A fallback image if no match is found
    end
  end

  # Maps a consumable name to its corresponding image filename
  def consumable_image_filename(consumable_name)
    case consumable_name
    when "Health Potion"
      "healthPotion.gif"
    when "Acid Potion"
      "acidPotion.gif"
    when "Revive"
      "revive.gif"
    when "Mana Refill"
      "invisibilityPotion.gif"
    else
      "defaultConsumable.gif"
    end
  end

end
