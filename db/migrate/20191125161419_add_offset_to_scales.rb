class AddOffsetToScales < ActiveRecord::Migration[6.0]
  def change
    add_column :scales, :offset, :integer
  end
end
