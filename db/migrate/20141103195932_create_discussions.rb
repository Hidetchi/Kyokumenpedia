class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.integer :position_id
      t.integer :user_id
      t.text :content
      t.integer :num

      t.timestamps
    end
  end
end
