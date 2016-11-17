$:.unshift File.expand_path('../../lib', __FILE__)
require './dbfactory/properties_dbfactory'
require 'cleric/yaml'
require 'cleric/pool'

def initialize_frontend_facade_data
  if ENV['PLATFORM'] == 'prod'
    return
  end
  pool = Cleric::Pool.new
  dbfactory = PropertiesDBFactory.new(pool.use(:db => 'Property_db'))
  data = dbfactory.query('select * from properties where id >= 999001')
  if data.empty?
    puts "initialize frontend facade data..."
    file = '../config/sql/properties.sql'
    File.open(file) do |file|
      file.each do |line|
        dbfactory.db << line
      end
    end

    dbfactory = PropertiesDBFactory.new(pool.use(:db => 'Listing_db'))
    file = '../config/sql/listings.sql'
    File.open(file) do |file|
      file.each do |line|
        dbfactory.db << line
      end
    end

    dbfactory = PropertiesDBFactory.new(pool.use(:db => 'Locations_db'))
    file = '../config/sql/locations.sql'
    File.open(file) do |file|
      file.each do |line|
        dbfactory.db << line
      end
    end
  end
end
