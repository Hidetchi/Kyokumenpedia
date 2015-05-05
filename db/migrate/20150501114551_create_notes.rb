class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.string :title
      t.text :content
      t.references :user, index: true
      t.references :position, index: true
      t.boolean :public, default: true
      t.integer :views, default: 0
      t.integer :category, default: 0

      t.timestamps
    end
  end
end
