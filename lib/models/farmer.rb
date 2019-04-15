class Farmer < ActiveRecord::Base
  has_many :farmer_plants
  has_many :plants, through: :farmer_plants


end
