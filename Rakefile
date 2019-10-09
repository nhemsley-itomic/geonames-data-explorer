require 'rubygems'
require 'erb'
require "active_record"
require "rails/generators"
require "rails"
require 'pry'
require 'csv'
require 'city-state'

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
    


end


load 'active_record/railties/databases.rake'