class AddIndexToGames < ActiveRecord::Migration
  def change
    add_index :games, :csa, :unique => true, :length => { :csa => 255 }
  end
end
