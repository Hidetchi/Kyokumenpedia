class AddColumnToPosition < ActiveRecord::Migration
  def change
    add_column :positions, :latest_post_id, :integer
  end
end
