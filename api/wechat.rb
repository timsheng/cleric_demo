require 'httparty'
require './lib/cleric'

class Wechat

  include HTTParty
  include Cleric

  case ENV['PLATFORM']
  when 'stage'
    base_uri 'https://wechat-stage.student.com/wechat'
  when 'live'
    puts "this is in live env"
  end


  # just for example "how to use method in accessors"
  count_table :lead

  def self.send_text_message payload
    post('', :body => payload)
  end

end
