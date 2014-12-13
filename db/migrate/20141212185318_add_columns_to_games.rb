class AddColumnsToGames < ActiveRecord::Migration
  def change
    add_column :games, :event, :string
    add_column :game_sources, :kifu_url_footer, :string, default: ""
  end
end
