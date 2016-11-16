require 'require_all'
puts File.expand_path('../../dbfactory', __FILE__)
# $LOAD_PATH.unshift(File.dirname(__FILE__)+ 'dbfactory')
# puts $:
puts require_all File.expand_path('../../dbfactory', __FILE__)+ "/properties_dbfactory"

# dbfactory = PropertiesDBFactory.new(@pool.use(:db => 'Property_db'))
# data = dbfactory.query('select * from properties where id >= 999001')
