class ChangeCalibrationToFloat < ActiveRecord::Migration[6.0]
  def change
    change_column :scales, :calibration, :float
  end
end
