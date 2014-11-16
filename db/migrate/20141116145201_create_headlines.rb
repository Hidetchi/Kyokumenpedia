class CreateHeadlines < ActiveRecord::Migration
  def change
    create_table :headlines do |t|
      t.string :name
      t.integer :position_id

      t.timestamps

      t.index :name, :unique => true
    end
  end
end
