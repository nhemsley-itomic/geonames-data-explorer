class CreateEnglishCounties < ActiveRecord::Migration[5.2]
  def change
    create_table :english_counties do |t|
      t.string :postcode
      t.string :latitude
      t.string :longitude
      t.string :eastings
      t.string :northings
      t.string :ward
      t.string :county
      t.string :population
    end
  end
end
