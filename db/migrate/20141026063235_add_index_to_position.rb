class AddIndexToPosition < ActiveRecord::Migration
  def change
    add_index :positions, :sfen, unique: true
  end
end
