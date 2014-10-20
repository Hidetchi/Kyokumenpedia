class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.integer :prev_position_id
      t.integer :next_position_id
      t.string :csa
      t.boolean :promote, :default => false
      t.boolean :vague, :default => false
      t.integer :stat1_total, :default => 0
      t.integer :stat2_total, :default => 0

      t.timestamps
    end
  end
end
