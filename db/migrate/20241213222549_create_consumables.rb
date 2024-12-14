class CreateConsumables < ActiveRecord::Migration[8.0]
  def change
    create_table :consumables do |t|
      t.string :name
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end