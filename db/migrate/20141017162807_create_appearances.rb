class CreateAppearances < ActiveRecord::Migration
  def change
    create_table :appearances do |t|
      t.references :game, index: true
      t.references :position, index: true
      t.integer :index

      t.timestamps
    end
  end
end
