class Geoname < ActiveRecord::Base
    has_one :city
    has_many :places
end