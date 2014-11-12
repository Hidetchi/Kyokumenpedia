class AddIndexToModel < ActiveRecord::Migration
  def change
    add_index :discussions, :position_id
    add_index :discussions, :created_at
    add_index :moves, :prev_position_id
    add_index :moves, :next_position_id
    add_index :moves, [:prev_position_id, :next_position_id], :unique => true
    add_index :watches, :user_id
    add_index :watches, :position_id
    add_index :wikiposts, :user_id
    add_index :wikiposts, :created_at
    add_index :positions, :views
    add_index :users, :point
  end
end
