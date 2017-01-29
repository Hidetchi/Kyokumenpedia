class CreateShogidb2Entries < ActiveRecord::Migration
  def change
    create_table :shogidb2_entries do |t|
      t.string :native_hash
      t.integer :result

      t.index :native_hash, unique: true
    end
  end
end
