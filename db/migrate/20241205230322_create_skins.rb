class CreateSkins < ActiveRecord::Migration[8.0]
  def change
    create_table :skins do |t|
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
