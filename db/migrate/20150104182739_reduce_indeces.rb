class ReduceIndeces < ActiveRecord::Migration
  def change
    remove_index :positions, :sfen
    add_index :positions, :sfen, length: 96
    remove_index :appearances, :game_id
    remove_index :moves, [:prev_position_id, :next_position_id]
    remove_index :games, :csa_hash
    add_index :games, :csa_hash, unique: true, length: 32 
  end
end
