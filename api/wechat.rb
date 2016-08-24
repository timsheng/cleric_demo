require 'httparty'

class Wechat
  include HTTParty

  # format :xml
  base_uri 'https://wechat-stage.student.com/wechat'
  # base_uri 'https://53498178.ngrok.io/app_dev.php/wechat'

  def self.send_text_message(payload)
    post('', :body => payload)
  end

end
