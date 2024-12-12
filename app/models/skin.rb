class Skin < ActiveRecord::Base
  belongs_to :user
  has_one_attached :image

  # Ensure only one skin can be marked as current
  validate :only_one_current_skin, if: -> { current }

  # Validate the presence of an archetype
  validates :archetype, presence: true, inclusion: { in: %w[Attacker Defender Healer], message: "%{value} is not a valid archetype" }

  after_initialize :set_default_stats, if: :new_record?

  # Set default stats based on archetype
  def set_default_stats
    case archetype
    when 'Attacker'
      self.attack ||= 30
      self.defense ||= 5
      self.iq ||= 10
      self.mana ||= 100
      self.special_attack ||= 40
      self.special_defense ||= 20
      self.health ||= 100
    when 'Defender'
      self.attack ||= 10
      self.defense ||= 30
      self.iq ||= 1
      self.mana ||= 50
      self.special_attack ||= 15
      self.special_defense ||= 35
      self.health ||= 200
    when 'Healer'
      self.attack ||= 20
      self.defense ||= 20
      self.iq ||= 5
      self.mana ||= 75
      self.special_attack ||= 25
      self.special_defense ||= 25
      self.health ||= 150
    else
      self.attack ||= 15
      self.defense ||= 15
      self.iq ||= 5
      self.mana ||= 60
      self.special_attack ||= 20
      self.special_defense ||= 20
      self.health ||= 120
    end
    self.level ||= 1
    self.experience ||= 0
  end

  # Level up logic for the skin
  def level_up
    self.experience -= self.level * 100
    self.level += 1
    stat_increase = case archetype
                    when 'Attacker'
                      { health: 20, attack: 10, defense: 5, iq: 3, mana: 20, special_attack: 10, special_defense: 5 }
                    when 'Defender'
                      { health: 30, attack: 5, defense: 10, iq: 1, mana: 10, special_attack: 5, special_defense: 10 }
                    when 'Healer'
                      { health: 25, attack: 7, defense: 7, iq: 2, mana: 15, special_attack: 7, special_defense: 7 }
                    else
                      { health: 25, attack: 7, defense: 7, iq: 2, mana: 15, special_attack: 4, special_defense: 4 }
                    end

    stat_increase.each { |stat, increment| self[stat] += increment }
    save!
  end

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
