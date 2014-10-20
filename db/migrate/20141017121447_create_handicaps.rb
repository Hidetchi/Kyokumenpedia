class CreateHandicaps < ActiveRecord::Migration
  def change
    create_table :handicaps do |t|
      t.string :name

      t.timestamps
    end
  end
end
