class Booth < ApplicationRecord
	has_many :scales
  has_many :thermometers
end
