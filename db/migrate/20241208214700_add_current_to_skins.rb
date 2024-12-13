class AddCurrentToSkins < ActiveRecord::Migration[8.0]
  def change
    add_column :skins, :current, :boolean
  end
end
