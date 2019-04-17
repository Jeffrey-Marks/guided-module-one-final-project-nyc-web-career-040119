class CreateFarmers < ActiveRecord::Migration[5.0]
  def change
    create_table :farmers do |t|
      t.string :name
      t.integer :money, default: 100
      t.integer :total_money_earned, default: 0
      t.integer :crops_harvested, default: 0
      # Might have money later!
    end
  end
end
