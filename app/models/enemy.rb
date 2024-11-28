# app/models/enemy.rb
class Enemy < ActiveRecord::Base
  belongs_to :game


  validates :health, :attack, :defense, :iq, presence: true, numericality: { only_integer: true }
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  after_initialize :set_default_stats, if: :new_record?

  def set_default_stats
    return if self.level.nil?

    self.health = 300 + (level * 20)
    self.attack = 20 + (level * 2)
    self.defense = 10 + (level * 2)
    self.iq = 5 + (level * 1)
    self.max_health = self.health
  end
end
