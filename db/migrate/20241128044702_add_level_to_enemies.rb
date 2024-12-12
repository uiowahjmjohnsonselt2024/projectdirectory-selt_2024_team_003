class AddLevelToEnemies < ActiveRecord::Migration[8.0]
  def change
    add_column :enemies, :level, :integer, default: 0
  end
end
