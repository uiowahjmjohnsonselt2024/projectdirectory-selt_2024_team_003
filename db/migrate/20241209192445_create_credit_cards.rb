class CreateCreditCards < ActiveRecord::Migration[8.0]
  def change
    create_table :credit_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.string :last4, null: false
      t.integer :expiration_month, null: false
      t.integer :expiration_year, null: false
      t.string :card_type, null: false

      t.timestamps
    end
  end
end
