class UpdateShardsColumnInUsers < ActiveRecord::Migration[8.0]
  def change
    # Set all existing NULL values to 0
    User.update_all(shards: 0)

    # Then apply the NOT NULL constraint and default value
    change_column_default :users, :shards, from: nil, to: 0
    change_column_null :users, :shards, false
  end
end
