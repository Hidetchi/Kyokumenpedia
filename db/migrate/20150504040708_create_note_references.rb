class CreateNoteReferences < ActiveRecord::Migration
  def change
    create_table :note_references do |t|
      t.references :note, index: true
      t.references :position, index: true
    end
  end
end
