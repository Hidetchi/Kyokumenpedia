class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :strength, :string
    add_column :users, :style, :string
    add_column :users, :url, :string
    add_column :users, :description, :string
    add_column :users, :point, :integer, :default => 0
    add_column :users, :name81, :string
  end
end
