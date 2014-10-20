class CreateStrategies < ActiveRecord::Migration
  def change
    create_table :strategies do |t|
      t.string :name
      t.integer :parent_strategy_id

      t.timestamps
    end
  end
end
