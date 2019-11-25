class Scale < ApplicationRecord
  belongs_to :booth
  has_many :weights
end
