class RenameColumnInStrategies < ActiveRecord::Migration
  def change
    rename_column :strategies, :parent_strategy_id, :strategy_group_id
  end
end
