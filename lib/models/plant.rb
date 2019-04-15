class Plant < ActiveRecord::Base
  has_many :farmer_plants
  has_many :farmers, through: :farmer_plants

  # def initialize
  #   self.days_since_planted = 0
  # end
end
