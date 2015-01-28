class CreateReferences < ActiveRecord::Migration
  def change
    create_table :pos_references do |t|
      t.integer :referrer_id
      t.integer :referred_id

      t.index :referrer_id
      t.index :referred_id
    end
  end
end
