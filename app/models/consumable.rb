class Consumable < ApplicationRecord
  belongs_to :user

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  # Increment the quantity of this consumable
  def increment_quantity(amount = 1)
    self.quantity += amount
    save
  end

  # Decrement the quantity of this consumable
  def decrement_quantity(amount = 1)
    self.quantity -= amount if self.quantity > 0
    save
  end
end
