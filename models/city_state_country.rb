class CityStateCountry < ActiveRecord::Base
    belongs_to :geoname, primary_key: :geoname_id
end