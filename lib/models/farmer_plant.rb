class FarmerPlant < ActiveRecord::Base
  belongs_to :farmer
  belongs_to :plant

  # def initialize
  #   self.update(days_since_planted: 0)
  #   self.update(alive: true)
  # end
end
