class ChangeColumnsInPosition < ActiveRecord::Migration
  def change
    add_column :positions, :views, :integer, :default => 0
    remove_column :positions, :csa
  end
end
