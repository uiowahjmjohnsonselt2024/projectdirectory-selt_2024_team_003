class AddStatsToSkins < ActiveRecord::Migration[8.0]
  def change
    add_column :skins, :attack, :integer
    add_column :skins, :defense, :integer
    add_column :skins, :iq, :integer
    add_column :skins, :mana, :integer
    add_column :skins, :special_attack, :integer
    add_column :skins, :special_defense, :integer
    add_column :skins, :health, :integer
    add_column :skins, :level, :integer
    add_column :skins, :experience, :integer
  end
end
