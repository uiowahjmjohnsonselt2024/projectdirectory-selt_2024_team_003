class AddArchetypeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :archetype, :string
  end
end
