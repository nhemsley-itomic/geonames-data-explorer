class EnglishCounty < ActiveRecord::Base

    def self.closest_postcode_to(lat, long)
        query = <<-SQL
        SELECT id, latitude, longitude, 111.045 * DEGREES(ACOS(COS(RADIANS(#{lat}))
         * COS(RADIANS(latitude))
         * COS(RADIANS(longitude) - RADIANS(#{long}))
         + SIN(RADIANS(#{lat}))
         * SIN(RADIANS(latitude))))
         AS distance_in_km
        FROM airports
        ORDER BY distance_in_km ASC
        LIMIT 0,5;
        SQL
    end
end