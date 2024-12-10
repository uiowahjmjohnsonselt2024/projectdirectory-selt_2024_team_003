class AddShardsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :shards, :integer
  end
end
