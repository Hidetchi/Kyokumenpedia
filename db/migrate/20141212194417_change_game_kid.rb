class ChangeGameKid < ActiveRecord::Migration
  def change
    reversible do |dir|
      change_table :games do |t|
        dir.up   { t.change :native_kid, :string }
        dir.down { t.change :native_kid, :integer }
      end
    end
  end
end
