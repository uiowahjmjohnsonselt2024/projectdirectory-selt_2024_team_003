class AddSpecialStatsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :mana, :integer
    add_column :users, :special_attack, :integer
    add_column :users, :special_defense, :integer
  end
end
