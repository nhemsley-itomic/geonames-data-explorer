class Geoname < ActiveRecord::Base
    has_one :city, primary_key: :geoname_id
    has_many :places

    has_one :state, primary_key: :geoname_id

    has_one :city_state_country, primary_key: :geoname_id

    scope :top, ->(count) {order(population_int: :desc).limit(count)}

end