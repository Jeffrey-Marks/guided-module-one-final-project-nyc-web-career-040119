class FarmerPlant < ActiveRecord::Base
  belongs_to :farmer
  belongs_to :plant
end
