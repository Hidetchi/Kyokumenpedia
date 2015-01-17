class AddCardToUsers < ActiveRecord::Migration
  def change
    add_column :users, :card, :integer, :default => 0
  end
end
