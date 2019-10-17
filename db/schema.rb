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

ActiveRecord::Schema.define(version: 2019_10_16_043843) do

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "geoname_id"
    t.integer "state_id"
    t.index ["geoname_id"], name: "index_cities_on_geoname_id"
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "city_state_countries", force: :cascade do |t|
    t.string "country_code"
    t.string "state"
    t.string "city"
    t.string "geoname_id"
    t.index ["geoname_id"], name: "index_city_state_countries_on_geoname_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
  end

  create_table "geonames", force: :cascade do |t|
    t.string "geoname_id"
    t.string "name"
    t.string "asciiname"
    t.string "alternatenames"
    t.string "latitude"
    t.string "longitude"
    t.string "feature_class"
    t.string "feature_code"
    t.string "country_code"
    t.string "cc2"
    t.string "admin1_code"
    t.string "admin2_code"
    t.string "admin3_code"
    t.string "admin4_code"
    t.string "population"
    t.string "elevation"
    t.string "dem"
    t.string "timezone"
    t.date "modification_date"
    t.integer "population_int"
    t.index ["geoname_id"], name: "index_geonames_on_geoname_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "name"
    t.integer "geoname_id"
    t.text "json_result"
    t.string "google_place_id"
    t.index ["geoname_id"], name: "index_places_on_geoname_id"
    t.index ["google_place_id"], name: "index_places_on_google_place_id", unique: true
  end

  create_table "spots", force: :cascade do |t|
    t.string "name"
    t.integer "city_id"
    t.text "json_result"
    t.string "google_place_id"
    t.index ["city_id"], name: "index_spots_on_city_id"
    t.index ["google_place_id"], name: "index_spots_on_google_place_id", unique: true
  end

  create_table "states", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "geoname_id"
    t.integer "country_id"
    t.index ["country_id"], name: "index_states_on_country_id"
  end

end
