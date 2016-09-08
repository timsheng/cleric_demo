require 'httparty'
require './lib/cleric'
require './lib/cleric/http'

class Booking
  include HTTParty
  include Cleric
  extend YAML

  debug_output $stdout

  http = http "#{self}_http"

  base_uri http[:base_uri]

  basic_auth http[:basic_auth]['user'], http[:basic_auth]['password']

  headers http[:headers]

  def get_student email
    self.class.get "/#{email}"
  end

end
