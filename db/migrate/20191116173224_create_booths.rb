class CreateBooths < ActiveRecord::Migration[6.0]
  def change
    create_table :booths do |t|
      t.string :name

      t.timestamps
    end
  end
end
