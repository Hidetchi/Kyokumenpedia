class RenameColumnInAppearance < ActiveRecord::Migration
  def change
    rename_column :appearances, :index, :num
  end
end
