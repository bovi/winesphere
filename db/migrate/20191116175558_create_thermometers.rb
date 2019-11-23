class CreateThermometers < ActiveRecord::Migration[6.0]
  def change
    create_table :thermometers do |t|
      t.string :name
      t.belongs_to :booth, null: false, foreign_key: true

      t.timestamps
    end
  end
end
