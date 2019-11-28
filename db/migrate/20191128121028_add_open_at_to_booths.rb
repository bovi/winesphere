class AddOpenAtToBooths < ActiveRecord::Migration[6.0]
  def change
    add_column :booths, :open_at, :datetime
  end
end
