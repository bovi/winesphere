class AddRawToWeights < ActiveRecord::Migration[6.0]
  def change
    add_column :weights, :raw, :integer
  end
end
