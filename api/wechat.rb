require './api/api'
require './lib/cleric'

class Wechat < API

  debug_output $stdout

  base_uri http('base_uri')

  # just for example "how to use method in accessors"
  count_table :lead

  def send_text_message payload
    self.class.post('', :body => payload)
  end

end
