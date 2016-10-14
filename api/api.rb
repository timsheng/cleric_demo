require './lib/cleric'
require 'httparty'
require 'base64'
require 'openssl'
require 'data_magic'


class API
  include Cleric
  include HTTParty
  include DataMagic

  # debug_output $stdout

  def self.http key, subkey = false
    http_conf = Cleric::YAML.fetch_corresponding_conf_by "#{self}_http"
    return http_conf[key][subkey] if subkey
    return http_conf[key] if key
  end

  def new_response response
    new_response = {}
    new_response.merge({:response => response, :result => response.parsed_response, :code => response.code})
  end

end
