class AddSpecialStatsToEnemies < ActiveRecord::Migration[8.0]
  def change
    add_column :enemies, :special_attack, :integer
    add_column :enemies, :special_defense, :integer
    add_column :enemies, :mana, :integer
    add_column :enemies, :max_mana, :integer
  end
end
