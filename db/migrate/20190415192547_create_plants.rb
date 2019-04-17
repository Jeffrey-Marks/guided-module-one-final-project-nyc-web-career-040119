class CreatePlants < ActiveRecord::Migration[5.0]
  def change
    create_table :plants do |t|
      t.string :name
      t.integer :days_to_grow
      t.integer :price
      t.integer :sells_for
      # Might have cost later!
    end
  end
end
