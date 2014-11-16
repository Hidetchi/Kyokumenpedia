class AddReceiveMailsToUser < ActiveRecord::Migration
  def change
    add_column :users, :receive_watching, :boolean, :default => true
    add_column :users, :receive_following, :boolean, :default => true
  end
end
