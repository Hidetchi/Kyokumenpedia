class AddColumnsToGame < ActiveRecord::Migration
  def change
    add_column :games, :handicap_id, :integer
    add_column :games, :csa, :text
    add_column :games, :game_source_id, :integer
  end
end
