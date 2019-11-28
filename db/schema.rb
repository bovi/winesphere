# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_28_121028) do

  create_table "booths", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "open_at"
  end

  create_table "scales", force: :cascade do |t|
    t.string "name"
    t.integer "booth_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "offset"
    t.float "calibration"
    t.index ["booth_id"], name: "index_scales_on_booth_id"
  end

  create_table "temperatures", force: :cascade do |t|
    t.float "temp"
    t.float "battery"
    t.integer "uptime"
    t.integer "thermometer_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["thermometer_id"], name: "index_temperatures_on_thermometer_id"
  end

  create_table "thermometers", force: :cascade do |t|
    t.string "name"
    t.integer "booth_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["booth_id"], name: "index_thermometers_on_booth_id"
  end

  create_table "weights", force: :cascade do |t|
    t.float "weight"
    t.float "battery"
    t.integer "uptime"
    t.integer "scale_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "raw"
    t.index ["scale_id"], name: "index_weights_on_scale_id"
  end

  add_foreign_key "scales", "booths"
  add_foreign_key "temperatures", "thermometers"
  add_foreign_key "thermometers", "booths"
  add_foreign_key "weights", "scales"
end
