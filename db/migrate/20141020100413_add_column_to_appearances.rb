class AddColumnToAppearances < ActiveRecord::Migration
  def change
    add_column :appearances, :next_move_id, :integer
  end
end
