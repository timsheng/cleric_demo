require './lib/cleric'
require 'httparty'
require 'base64'
require 'openssl'


class API
  include Cleric
  include HTTParty

  # debug_output $stdout

  def self.http key, subkey = false
    http_conf = Cleric::YAML.fetch_corresponding_conf_by "#{self}_http"
    return http_conf[key][subkey] if subkey
    return http_conf[key] if key
  end

end
