require 'rubygems'

require "active_record"
require "rails/generators"
require "rails"

require 'pry'
require 'csv'
require 'city-state'
require 'google_places'

require_relative 'models/models'

include ActiveRecord::Tasks

class SeedLoader
  def initialize(seed_file)
    @seed_file = seed_file
  end
  def load_seed
    raise "Seed file '#{@seed_file}' does not exist" unless File.file?(@seed_file)
    load @seed_file
  end
end

CREDENTIALS = YAML.load(IO.read('config/credentials.yml'))


DatabaseTasks.env = ENV['ENV'] || 'development'
DatabaseTasks.root = File.dirname(__FILE__)
DatabaseTasks.database_configuration = YAML.load(File.read('database.yml'))
DatabaseTasks.db_dir = 'db'
DatabaseTasks.migrations_paths= 'db/migrate'
DatabaseTasks.seed_loader = SeedLoader.new('db/seeds.rb')
task :environment do
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Base.establish_connection DatabaseTasks.env.to_sym
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
        record = Hash[geoname_fields.zip(row)]
        Geoname.create(record)
      end

  end
    
  desc "Search Places"
  task :search_places => :environment do

    places_client = GooglePlaces::Client.new(CREDENTIALS.dig('google', 'places', 'api_key'))

    Country.all.each do |country|
      country.states.each do |state|
        state.cities.each do |city|
          qualified_city_name = "#{city.name}, #{city.state.name}, #{city.state.country.name}"
          unless city.geoname.nil? || city.spots
            #within a radius of 100km
            spots = places_client.spots(city.geoname.latitude, city.geoname.longitude, name: 'squash', radius: 40000)
            spots.each do |google_spot|
              begin
                spot = Spot.create(name: google_spot.name, city: city, json_result: JSON.dump(google_spot.json_result_object), google_place_id: google_spot.place_id)
                puts "Adding spot: #{google_spot.name} (#{city.name}, #{state.name}, #{country.name})"

              rescue ActiveRecord::RecordNotUnique => e
                #spot place_id is not unique (probably)
                puts "\tError adding spot: #{google_spot.name} (#{city.name}, #{state.name}, #{country.name})"
              end
            end
          end
        end
      end
    end
  end

  desc "Search Places"
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

  desc "populate population_int field"
  task :population_int => :environment do
    Geoname.all.each do |geoname|
      geoname.population_int = geoname.population.to_i
      geoname.save
    end
  end


  desc "Export places [csv|json]"
  task :export, [:format] => :environment do |task, args|
    places = Place.all

    headers = [:name, :physical_address, :suburb, :state, :country, :country_code, :postal_address, :telephone, :website, :email, 
              :fb_page_url, :g_place_id, :latitude, :longitude, :g_map_url, :types, :status, :venue_image]
    
    output = []
    places.each do |place|
      place_json = JSON.load(place.json_result)
      begin
        (lat, long) = [place_json['geometry']['location']['lat'], place_json['geometry']['location']['lng']] 
        google_url = "https://www.google.com/maps/search/?api=1&query=Google&query_place_id=#{place_json['place_id']}"
        line = [place_json['name'], place_json['plus_code']['compound_code'], nil, nil, nil, place.geoname.country_code, nil, nil, nil, nil, nil, place_json['place_id'], lat, long, google_url, place_json['types'].join(';'), 0, nil]
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