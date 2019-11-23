class CreateTemperatures < ActiveRecord::Migration[6.0]
  def change
    create_table :temperatures do |t|
      t.float :temp
      t.float :battery
      t.integer :uptime
      t.belongs_to :thermometer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
