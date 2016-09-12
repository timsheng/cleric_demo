require 'httparty'
require './lib/cleric'

class Wechat

  include HTTParty
  include Cleric

  # debug_output $stdout

  def self.http key, subkey = false
    http_conf = Cleric::YAML.fetch_corresponding_conf_by "#{self}_http"
    return http_conf[key][subkey] if subkey
    return http_conf[key] if key
  end

  base_uri http('base_uri')

  # just for example "how to use method in accessors"
  count_table :lead

  def send_text_message payload
    self.class.post('', :body => payload)
  end

end
