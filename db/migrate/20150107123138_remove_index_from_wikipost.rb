class RemoveIndexFromWikipost < ActiveRecord::Migration
  def change
    remove_index :wikiposts, :created_at
  end
end
