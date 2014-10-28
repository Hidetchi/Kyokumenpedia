class CreateWikiposts < ActiveRecord::Migration
  def change
    create_table :wikiposts do |t|
      t.integer :position_id
      t.integer :user_id
      t.text :content
      t.string :comment
      t.boolean :minor
      t.integer :prev_post_id

      t.timestamps
    end
    add_index :wikiposts, :position_id
  end
end
