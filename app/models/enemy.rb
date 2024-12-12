# app/models/enemy.rb
class Enemy < ActiveRecord::Base
  belongs_to :game

  validates :health, :attack, :defense, :iq, :special_attack, :special_defense, :mana, presence: true,
                                                                                       numericality: { only_integer: true }
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  after_initialize :set_default_stats, if: :new_record?

  def set_default_stats
    return if level.nil?

    self.health = 300 + (level * 20)
    self.attack = 20 + (level * 2)
    self.defense = 10 + (level * 2)
    self.iq = 5 + (level * 1)
    self.special_attack = 15 + (level * 3)
    self.special_defense = 10 + (level * 2)
    self.mana = 50 + (level * 5)
    self.max_health = health
    self.max_mana = mana
  end

  def use_mana(amount)
    return false if amount > mana

    self.mana -= amount
    save
  end
end
