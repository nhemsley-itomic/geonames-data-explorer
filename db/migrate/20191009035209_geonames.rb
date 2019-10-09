class Geonames < ActiveRecord::Migration[5.2]
  def change
    create_table :geonames do |t|
      t.string :geoname_id
      t.string :name
      t.string :asciiname
      t.string :alternatenames
      t.string :latitude
      t.string :longitude
      t.string :feature_class
      t.string :feature_code
      t.string :country_code
      t.string :cc2
      t.string :admin1_code
      t.string :admin2_code
      t.string :admin3_code
      t.string :admin4_code
      t.string :population
      t.string :elevation
      t.string :dem
      t.string :timezone
      t.date :modification_date

      t.index :geoname_id
    end
  end
end
