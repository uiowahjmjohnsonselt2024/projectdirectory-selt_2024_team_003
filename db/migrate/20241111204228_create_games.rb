class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :name
      t.string :code
      # need to reference game owner

      t.timestamps null: false
    end
  end
end
