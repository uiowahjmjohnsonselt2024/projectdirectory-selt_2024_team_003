class AddDefaultsToGameUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_default :game_users, :x_position, 0
    change_column_default :game_users, :y_position, 0
  end
end
