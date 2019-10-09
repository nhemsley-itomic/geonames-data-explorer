class CreateStates < ActiveRecord::Migration[5.2]
  def change
    create_table :states do |t|
      t.string :name
      t.string :code
      t.string :geoname_id
      t.references :country
    end
  end
end
