require 'cleric/db'
class PropertiesDBFactory < Cleric::DBFactory

  column :booking_student, :table => 'student'
  column :identity_user, :table => 'user'
  column :universities, :table => 'universities'
  column :locations_countries, :table => 'countries'
  column :locations_cities, :table => 'cities'
  column :locations_areas, :table => 'areas'

end
