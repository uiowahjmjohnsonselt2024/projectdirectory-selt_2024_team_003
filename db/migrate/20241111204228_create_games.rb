class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :name
      t.string :code
      # need to reference game owner

      t.timestamps null: false
    end
  end
end
