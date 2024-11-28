# app/models/enemy.rb
class Enemy < ActiveRecord::Base
  belongs_to :game

  # Validations for enemy stats
  validates :health, :attack, :defense, :iq, presence: true, numericality: { only_integer: true }
  after_initialize :set_default_max_health, if: :new_record?
  def set_default_max_health
    self.max_health ||= 100 # Default max health if not set
  end
end
