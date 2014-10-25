class AddColumnToMoves < ActiveRecord::Migration
  def change
    add_column :moves, :capture, :boolean, :default => false
  end
end
