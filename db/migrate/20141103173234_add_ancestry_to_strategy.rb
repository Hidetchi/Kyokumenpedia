class AddAncestryToStrategy < ActiveRecord::Migration
  def change
    remove_column :strategies, :strategy_group_id
    add_column :strategies, :ancestry, :string
    
    add_index :strategies, :ancestry
  end
end
