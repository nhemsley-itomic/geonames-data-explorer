class CreateCities < ActiveRecord::Migration[5.2]
  def change
    create_table :cities do |t|
      t.string :name
      t.string :code
      t.string :geoname_id
      t.string :latitude
      t.string :longitude

      t.references :state
    end
  end
end
