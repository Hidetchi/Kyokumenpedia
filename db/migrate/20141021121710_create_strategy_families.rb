class CreateStrategyFamilies < ActiveRecord::Migration
  def change
    create_table :strategy_families do |t|
      t.string :name

      t.timestamps
    end
  end
end
