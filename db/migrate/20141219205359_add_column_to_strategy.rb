class AddColumnToStrategy < ActiveRecord::Migration
  def change
    add_column :strategies, :main_position_id, :integer
  end
end
