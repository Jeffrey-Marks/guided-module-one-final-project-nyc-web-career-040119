class Farmer < ActiveRecord::Base
  has_many :farmer_plants
  has_many :plants, through: :farmer_plants

  def display_name
    self.name.split.map(&:capitalize).join(' ')
  end

  def self.richest_farmers
    self.all.order(total_money_earned: :desc).first(3)
  end

  def self.greenest_farmers
    self.all.order(crops_harvested: :desc).first(3)
  end
end
