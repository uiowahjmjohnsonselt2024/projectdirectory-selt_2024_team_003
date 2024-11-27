class AddPositionToGameUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :game_users, :x_position, :integer
    add_column :game_users, :y_position, :integer
  end
end
