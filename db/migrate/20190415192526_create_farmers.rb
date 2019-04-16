class CreateFarmers < ActiveRecord::Migration[5.0]
  def change
    create_table :farmers do |t|
      t.string :name
      t.integer :crops_harvested
      # Might have money later!
    end
  end
end
