class CreateCityStateCountries < ActiveRecord::Migration[5.2]
  def change
    create_table :city_state_countries do |t|
      t.string :country_code
      t.string :state
      t.string :city
      t.string :geoname_id

      t.index :geoname_id
    end
  end
end
