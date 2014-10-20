class CreateGameSources < ActiveRecord::Migration
  def change
    create_table :game_sources do |t|
      t.string :name
      t.string :pass
      t.string :kifu_url_header

      t.timestamps
    end
  end
end
