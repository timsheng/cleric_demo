require 'cleric'
module PropertiesSQL
  include Cleric

  column :booking_student, :table => 'student'
  column :identity_user, :table => 'user'
end
