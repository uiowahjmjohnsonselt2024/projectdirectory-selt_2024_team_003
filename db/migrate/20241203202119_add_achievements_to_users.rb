class AddAchievementsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :achievements, :json
  end
end