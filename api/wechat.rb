require 'httparty'
require './lib/cleric'

class Wechat

  include HTTParty
  include Cleric

  base_uri 'https://wechat-stage.student.com/wechat'

  # just for example "how to use method in accessors"
  count_table :lead

  def self.send_text_message payload
    post('', :body => payload)
  end

end
