class AddCurrentToWeapons < ActiveRecord::Migration[8.0]
  def change
    add_column :weapons, :current, :boolean, default: false
  end
end
