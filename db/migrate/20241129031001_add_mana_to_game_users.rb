class AddManaToGameUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :game_users, :mana, :integer
  end
end
