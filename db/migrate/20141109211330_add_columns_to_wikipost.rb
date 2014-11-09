class AddColumnsToWikipost < ActiveRecord::Migration
  def change
    add_column :wikiposts, :adds, :integer
    add_column :wikiposts, :dels, :integer
  end
end
