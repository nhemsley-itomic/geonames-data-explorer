class CreatePlaces < ActiveRecord::Migration[5.2]
  def change
    create_table :places do |t|
      t.string :name
      t.references :geoname
      t.text :json_result
      
      t.string :google_place_id
      t.index :google_place_id, unique: true
    end
  end
end
