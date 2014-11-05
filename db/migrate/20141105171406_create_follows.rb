class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.integer :follower_id
      t.integer :followed_id
      t.boolean :check_all, :default => false

      t.timestamps
      
      t.index [:follower_id, :followed_id], :unique => true
    end
  end
end
