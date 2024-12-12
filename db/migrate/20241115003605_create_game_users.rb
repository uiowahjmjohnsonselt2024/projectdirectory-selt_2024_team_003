class CreateGameUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :game_users do |t|
      t.references :user, index: true, foreign_key: true
      t.references :game, index: true, foreign_key: true
    end
  end
end
