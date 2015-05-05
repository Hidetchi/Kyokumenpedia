class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :user, index: true
      t.references :note, index: true
      t.text :content
      t.integer :num

      t.timestamps
    end
  end
end
