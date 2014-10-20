class AddIndexToGames < ActiveRecord::Migration
  def change
    add_index :games, :csa, :unique => true
  end
end
