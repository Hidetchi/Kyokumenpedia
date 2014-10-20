class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :black_name
      t.string :white_name
      t.integer :black_rate
      t.integer :white_rate
      t.date :date
      t.integer :result
      t.integer :native_kid

      t.timestamps
    end
  end
end
