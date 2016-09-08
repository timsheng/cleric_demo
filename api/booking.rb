require 'httparty'
require './lib/cleric'
require './lib/cleric/http'
require 'base64'
require 'openssl'

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
    path = "/api/v3/student/#{email}"
    self.class.headers generate_token(path)
    self.class.get path
  end

  def generate_token(payload)
    shared_secret = '234kjkj324kjh23jk4h234jkhk23j4'
    token = Base64.encode64(OpenSSL::HMAC.digest('sha1', shared_secret, payload))
    puts token
    return {'X-OSL-TOKEN' => token}
  end

end
