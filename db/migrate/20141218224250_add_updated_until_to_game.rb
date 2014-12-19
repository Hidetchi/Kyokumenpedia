class AddUpdatedUntilToGame < ActiveRecord::Migration
  def change
    add_column :games, :updated_until, :integer, :default => -1
  end
end
