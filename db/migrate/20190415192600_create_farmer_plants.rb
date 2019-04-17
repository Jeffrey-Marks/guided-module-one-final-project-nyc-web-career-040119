class CreateFarmerPlants < ActiveRecord::Migration[5.0]
  def change
    create_table :farmer_plants do |t|
      t.integer :farmer_id
      t.integer :plant_id
      t.integer :plot_number # A number from 1-5
      t.integer :days_since_planted, default: 0
      t.boolean :alive, default: true
    end
  end
end
