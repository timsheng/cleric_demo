require './api/api'

class Wechat < API

  base_uri http('base_uri')

  # just for example "how to use method in accessors"

  def send_text_message payload
    self.class.post('', :body => payload.to_xml)
  end

end
