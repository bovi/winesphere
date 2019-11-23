class CreateWeights < ActiveRecord::Migration[6.0]
  def change
    create_table :weights do |t|
      t.float :weight
      t.float :battery
      t.integer :uptime
      t.belongs_to :scale, null: false, foreign_key: true

      t.timestamps
    end
  end
end
