class AddLevelToGameUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :game_users, :level, :integer, default: 1
  end
end
