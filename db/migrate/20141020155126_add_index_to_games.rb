class AddIndexToGames < ActiveRecord::Migration
  def change
    add_column :games, :csa_hash, :string
    add_index :games, :csa_hash, :unique => true
  end
end
