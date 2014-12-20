class CreateEditorPickups < ActiveRecord::Migration
  def change
    create_table :editor_pickups do |t|
      t.integer :position_id
      t.integer :user_id
      t.string :comment

      t.timestamps
    end
  end
end
