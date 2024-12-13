class Weapon < ApplicationRecord
  belongs_to :user
  validates :name, presence: true

  # Ensure only one weapon is marked as current
  validate :only_one_current_weapon, if: -> { current }

  # Public method to set this weapon as current
  def set_as_current_weapon
    user.weapons.update_all(current: false) # Reset all current flags for the user's weapons
    update!(current: true) # Mark this weapon as current
  end

  private

  # Validation to ensure only one weapon is marked as current
  def only_one_current_weapon
    return unless Weapon.where(user_id: user_id, current: true).where.not(id: id).exists?

    errors.add(:current, 'There can only be one current weapon for a user.')
  end
end
