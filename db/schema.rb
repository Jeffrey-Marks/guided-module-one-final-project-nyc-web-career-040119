# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190415192600) do

  create_table "farmer_plants", force: :cascade do |t|
    t.integer "farmer_id"
    t.integer "plant_id"
    t.integer "plot_number"
    t.integer "days_since_planted"
    t.boolean "alive"
  end

  create_table "farmers", force: :cascade do |t|
    t.string  "name"
    t.integer "crops_harvested"
  end

  create_table "plants", force: :cascade do |t|
    t.string  "name"
    t.integer "days_to_grow"
  end

end
