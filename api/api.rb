require './lib/cleric'
require 'httparty'
require 'data_magic'

class API
  include Cleric
  include HTTParty
  include DataMagic

  attr_accessor :new_headers
  # debug_output $stdout

  def self.http key, subkey = nil
    http_conf = Cleric::YAML.fetch_corresponding_conf_by "#{self}_http"
    return http_conf[key][subkey] if subkey
    return http_conf[key] if key
  end

  def new_response response
    new_response = {}
    new_response.merge({:response => response, :message => response.parsed_response, :status => response.code})
  end

  def add_headers value
    @new_headers ||= {}
    @new_headers = @new_headers.merge(value.to_hash)
    return @new_headers
  end
end
