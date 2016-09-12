require 'httparty'
require './lib/cleric'
require 'base64'
require 'openssl'

class Booking
  
  include HTTParty
  include Cleric

  # debug_output $stdout

  def self.http key, subkey = false
    http_conf = Cleric::YAML.fetch_corresponding_conf_by "#{self}_http"
    return http_conf[key][subkey] if subkey
    return http_conf[key] if key
  end

  base_uri http('base_uri')

  basic_auth http('basic_auth','user'), http('basic_auth','password')

  headers http('headers')

  def get_student email
    path = "/api/v3/student/#{email}"
    self.class.headers generate_token(path)
    self.class.get path
  end

  def generate_token(payload)
    shared_secret = self.class.http('shared_secret')
    token = Base64.encode64(OpenSSL::HMAC.digest('sha1', shared_secret, payload))
    return {'X-OSL-TOKEN' => token}
  end

end
