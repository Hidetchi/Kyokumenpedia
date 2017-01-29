class CreateShogidb2Entries < ActiveRecord::Migration
  def change
    create_table :shogidb2_entries do |t|
      t.string :hash
      t.integer :result

      t.index :hash, unique: true
    end
  end
end
