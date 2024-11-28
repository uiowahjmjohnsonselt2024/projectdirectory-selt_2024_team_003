# app/models/enemy.rb
class Enemy < ActiveRecord::Base
  belongs_to :game


  validates :health, :attack, :defense, :iq, presence: true, numericality: { only_integer: true }
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  after_initialize :set_default_max_health, if: :new_record?
  def set_default_max_health
    self.max_health ||= 100
  end
end
