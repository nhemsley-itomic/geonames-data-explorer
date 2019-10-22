require 'rubygems'
require 'bundler/setup'

require "rails/generators"
require "rails"

require "active_record"

require 'pry'
require 'csv'
require 'city-state'
require 'google_places'

require 'geonames'

require_relative 'models/models'

include ActiveRecord::Tasks


CREDENTIALS = YAML.load(IO.read('config/credentials.yml'))

DatabaseTasks.env = ENV['ENV'] || 'development'
DatabaseTasks.root = File.dirname(__FILE__)
DatabaseTasks.database_configuration = YAML.load(File.read('database.yml'))
DatabaseTasks.db_dir = 'db'
DatabaseTasks.migrations_paths= 'db/migrate'

task :environment do
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection DatabaseTasks.env.to_sym

  ActiveRecord::Base.logger = ActiveSupport::Logger.new(Pathname.new(DatabaseTasks.root).join('tmp', 'query.log'))
end

namespace :db do
  desc "Creates a new migration file with the specified name"
  task :generate, :name, :options do |t, args|
    name, options = args[:name] || ENV['name'], args[:options] || ENV['options']
    unless name
      puts "Error: must provide name of migration to generate."
      puts "For example: rake #{t.name} name=add_field_to_form"
      abort
    end

    if options
      generator_params = [name] + options.gsub('/', ' ').split(" ")
    else
      generator_params = [name]
    end
    Rails::Generators.invoke "active_record:migration", generator_params, :destination_root => DatabaseTasks.root
  end
end

namespace :load do
  
  desc "Load pry"
  task :pry => :environment do

      binding.pry
  end

  desc "Update city-state gem data files"
  task :update_city_state => :environment do
    CS.update
  end

  desc "Load countries, states and cities"
  task :countries_states_cities => :environment do

    Country.delete_all
    State.delete_all
    City.delete_all
    countries = CS.countries.map{|k, v| {code: k, name: v}}

    countries.each do|country|
        (country_code, name) = country.values
        country_model = Country.create(code: country_code, name: name)

        country[:states] = CS.states(country_code).map {|state_code, name| {state_code: state_code, name: name}}
    
        country[:states].each do |state|
          state_model = State.create(country: country_model, code: state[:state_code], name: state[:name][:state_name], geoname_id: state[:name][:geoname_id])
          
          state[:cities] = CS.cities(state[:state_code], country_code)

          state[:cities].each do |city|
            city_model = City.create(state: state_model, name: city[:city_name], geoname_id: city[:geoname_id])
          end
        end
    end
  end

  desc "Import geonames data"
  task :geonames => :environment do
    geoname_fields = %w(geoname_id
      name
      asciiname
      alternatenames
      latitude
      longitude
      feature_class
      feature_code
      country_code
      cc2
      admin1_code
      admin2_code
      admin3_code
      admin4_code
      population
      elevation
      dem
      timezone
      modification_date)
    
    countries_file = Pathname.new(DatabaseTasks.root).join('tmp', 'cities500.txt')
    Geoname.delete_all
    CSV.foreach(countries_file, :col_sep => "\t", :quote_char => ">") do |row|
      record = HashWithIndifferentAccess[geoname_fields.zip(row)]
      record[:population_int] = record[:population].to_i

      Geoname.create(record)
    end

  end

  desc "Import Country Region City Data (from https://www.ip2location.com/free/geoname-id)"
  task :country_region_city => :environment do
    geoname_fields = %w(country_code state city geoname_id)
    
    countries_file = Pathname.new(DatabaseTasks.root).join('tmp', 'city-state-country.csv')
    CityStateCountry.delete_all
    CSV.foreach(countries_file, :col_sep => ",", :quote_char => '"') do |row|
      record = HashWithIndifferentAccess[geoname_fields.zip(row)]
      CityStateCountry.create(record)
    end

  end

  desc "Search Via Geonames -- Warning Expensive Script. THIS WILL COST ITOMIC MONEY IF RAN WITH AN API_KEY"
  task :search_geonames => :environment do

    places_client = GooglePlaces::Client.new(CREDENTIALS.dig('google', 'places', 'api_key'))

    count = 0

    cities = Geoname.where("population_int > ?", 100000)
    # cities = cities.take(20)

    cities.each do |city|
      count = count + 1
      puts "#{city.name} #{count}"
      places = places_client.spots(city.latitude, city.longitude, name: 'squash', radius: 40000)
      places.each do |google_spot|
        begin
          place = Place.create(name: google_spot.name, geoname: city, json_result: JSON.dump(google_spot.json_result_object), google_place_id: google_spot.place_id)
          puts "Adding spot: #{google_spot.name} (#{city.name})"

        rescue ActiveRecord::RecordNotUnique => e
          #spot place_id is not unique (probably)
          puts "\tError adding spot: #{google_spot.name} (#{city.name})"
        end
      end

    end
  end

  desc "load english shires"
  task :english_counties => :environment do
    counties = JSON.load(IO.read('tmp/english-counties.json'))
    counties.each do |county|
      EnglishCounty.create(county)
    end
  end

  desc "Export places [csv|json]"
  task :export, [:format] => :environment do |task, args|
    places = Place.includes(:geoname).all

    headers = [:name, :physical_address, :suburb, :state, :country, :country_code, :postal_address, :telephone, :website, :email, 
              :fb_page_url, :g_place_id, :latitude, :longitude, :g_map_url, :types, :status, :venue_image]
    
    output = []
    places.each do |place|
      place_json = JSON.load(place.json_result)
      begin
        (lat, long) = [place_json['geometry']['location']['lat'], place_json['geometry']['location']['lng']] 
        google_url = "https://www.google.com/maps/search/?api=1&query=Google&query_place_id=#{place_json['place_id']}"
        line = [place_json['name'], place_json['plus_code']['compound_code'], place.geoname.city_state_country&.city, place.geoname.city_state_country&.state, Country.where(code: place.geoname.city_state_country&.country_code).first&.name, place.geoname.city_state_country&.country_code, nil, nil, nil, nil, nil, place_json['place_id'], lat, long, google_url, place_json['types'].join(';'), 0, nil]
        output << line
      rescue Exception => e
      end
    end

     if args[:format].eql? 'csv'
      csv_output = CSV.generate(write_headers: true, headers: headers, col_sep: "\t") do |csv|
        output.each do |line|
          csv << line
        end
      end
      puts csv_output
    elsif args[:format].eql? 'json'
      puts JSON.dump(output)
    end

  end


end


load 'active_record/railties/databases.rake'