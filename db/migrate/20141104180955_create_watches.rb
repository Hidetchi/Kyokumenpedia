class CreateWatches < ActiveRecord::Migration
  def change
    create_table :watches do |t|
      t.integer :user_id
      t.integer :position_id
      t.boolean :check_all, :default => false

      t.timestamps
      
      t.index [:user_id, :position_id], :unique => true
    end    
  end
end
