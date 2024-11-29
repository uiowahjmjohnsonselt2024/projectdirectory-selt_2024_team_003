class AddMaxHealthToEnemies < ActiveRecord::Migration[8.0]
  def change
    add_column :enemies, :max_health, :integer, default: 300
  end
end
