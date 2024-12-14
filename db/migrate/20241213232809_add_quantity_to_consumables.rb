class AddQuantityToConsumables < ActiveRecord::Migration[8.0]
  def change
    add_column :consumables, :quantity, :integer, default: 0, null: false
  end
end
