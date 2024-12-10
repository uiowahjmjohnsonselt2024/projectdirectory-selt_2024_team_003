class AddArchetypeToSkins < ActiveRecord::Migration[8.0]
  def change
    add_column :skins, :archetype, :string
  end
end
