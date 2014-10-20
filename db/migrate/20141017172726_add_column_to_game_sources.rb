class AddColumnToGameSources < ActiveRecord::Migration
  def change
    add_column :game_sources, :category, :integer
  end
end
