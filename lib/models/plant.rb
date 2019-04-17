class Plant < ActiveRecord::Base
  has_many :farmer_plants
  has_many :farmers, through: :farmer_plants
end
