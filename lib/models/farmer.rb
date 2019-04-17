class Farmer < ActiveRecord::Base
  has_many :farmer_plants
  has_many :plants, through: :farmer_plants

  def display_name
        self.name.split.map(&:capitalize).join(' ')
  end

end
