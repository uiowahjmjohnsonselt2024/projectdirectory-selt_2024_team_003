class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.integer :recipient_id, null: false
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
