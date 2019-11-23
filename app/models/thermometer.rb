class Thermometer < ApplicationRecord
  belongs_to :booth
  has_many :temperatures
end
