class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :isbn13
      t.string :title
      t.string :author
      t.string :publisher
      t.date :publication_date

      t.timestamps
      
      t.index :isbn13, :unique => true
    end
  end
end
