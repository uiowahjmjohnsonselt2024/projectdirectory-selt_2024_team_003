class CreateEnemies < ActiveRecord::Migration[8.0]
  def change
    create_table :enemies do |t|
      t.string :name
      t.integer :health, default: 300
      t.integer :attack, default: 20
      t.integer :defense, default: 10
      t.integer :iq, default: 5
      t.references :game, foreign_key: true
      t.integer :x_position
      t.integer :y_position

      t.timestamps
    end
  end
end
