class CreateStrategyGroups < ActiveRecord::Migration
  def change
    create_table :strategy_groups do |t|
      t.string :name
      t.integer :strategy_family_id

      t.timestamps
    end
  end
end
