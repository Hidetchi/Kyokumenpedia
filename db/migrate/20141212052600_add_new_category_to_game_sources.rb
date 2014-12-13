class AddNewCategoryToGameSources < ActiveRecord::Migration
  def change
    add_column :moves, :stat3_total, :integer, default: 0
    add_column :positions, :stat3_black, :integer, default: 0
    add_column :positions, :stat3_white, :integer, default: 0
    add_column :positions, :stat3_draw, :integer, default: 0
  end
end
