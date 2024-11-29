class AddHealthToGameUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :game_users, :health, :integer, default: 100
  end
end
