class AddGeonameIdToCities < ActiveRecord::Migration[5.2]
  def change
      add_index :cities, :geoname_id 
  end
end
