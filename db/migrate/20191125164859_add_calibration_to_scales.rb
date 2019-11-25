class AddCalibrationToScales < ActiveRecord::Migration[6.0]
  def change
    add_column :scales, :calibration, :integer
  end
end
