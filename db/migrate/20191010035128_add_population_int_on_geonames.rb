class AddPopulationIntOnGeonames < ActiveRecord::Migration[5.2]
  def change
    add_column :geonames, :population_int, :int
end
end
