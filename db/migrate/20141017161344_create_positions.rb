class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string :sfen
      t.text :csa
      t.integer :handicap_id
      t.integer :strategy_id
      t.integer :stat1_black, :default => 0
      t.integer :stat1_white, :default => 0
      t.integer :stat1_draw, :default => 0
      t.integer :stat2_black, :default => 0
      t.integer :stat2_white, :default => 0
      t.integer :stat2_draw, :default => 0

      t.timestamps
    end
  end
end
