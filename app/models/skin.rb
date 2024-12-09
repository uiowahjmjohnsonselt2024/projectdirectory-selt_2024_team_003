class Skin < ActiveRecord::Base
  belongs_to :user
  has_one_attached :image

  # Ensure only one skin can be marked as current
  validate :only_one_current_skin, if: -> { current }

  # Validate the presence of an image
  validate :image_presence

  # Scope to get the current skin
  scope :current, -> { where(current: true).first }

  private

  # Validation to ensure only one skin is marked as current
  def only_one_current_skin
    return unless Skin.where(user_id: user_id, current: true).where.not(id: id).exists?

    errors.add(:current, 'There can only be one current skin for a user.')
  end

  # Validation to ensure an image is attached
  def image_presence
    errors.add(:image, 'must be attached') unless image.attached?
  end
end
