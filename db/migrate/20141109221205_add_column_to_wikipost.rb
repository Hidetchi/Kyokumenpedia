class AddColumnToWikipost < ActiveRecord::Migration
  def change
    add_column :wikiposts, :likes, :integer, :default => 0
  end
end
