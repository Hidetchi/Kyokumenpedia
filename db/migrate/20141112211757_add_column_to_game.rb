class AddColumnToGame < ActiveRecord::Migration
  def change
    add_column :games, :relation_updated, :boolean, :default => false
  end
end
