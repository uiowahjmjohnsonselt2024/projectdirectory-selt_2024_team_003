class AddStatsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :health, :integer, default: 100
    add_column :users, :attack, :integer, default: 10
    add_column :users, :defense, :integer, default: 5
    add_column :users, :iq, :integer, default: 1
  end
end
