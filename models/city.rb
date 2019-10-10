class City < ActiveRecord::Base
    belongs_to :state
    belongs_to :geoname, primary_key: :geoname_id
    has_many :spots
end