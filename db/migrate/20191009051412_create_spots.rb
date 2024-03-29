class CreateSpots < ActiveRecord::Migration[5.2]
  def change
    create_table :spots do |t|
      t.string :name
      t.references :city
      t.text :json_result
      
      t.string :google_place_id
      t.index :google_place_id, unique: true
    end
  end
end
