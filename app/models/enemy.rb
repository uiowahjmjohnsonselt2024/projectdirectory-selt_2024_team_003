# app/models/enemy.rb
class Enemy < ActiveRecord::Base
  belongs_to :game

  # Validations for enemy stats
  validates :health, :attack, :defense, :iq, presence: true, numericality: { only_integer: true }
end
