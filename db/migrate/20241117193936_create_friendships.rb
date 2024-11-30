class CreateFriendships < ActiveRecord::Migration[8.0]
  def change
    create_table :friendships do |t|
      t.references :user, { to_table: :users }, index: true
      t.references :friend, { to_table: :users }, index: true

      t.timestamps null: false
    end
  end
end
