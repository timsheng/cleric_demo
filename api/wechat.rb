require './api/api'

class Wechat < API

  base_uri http('base_uri')

  # just for example "how to use method in accessors"
  row :lead, :table => 'lead'
  row :session, :table => 'session'
  row :account_binding, :table => 'account_binding'

  def send_text_message payload
    self.class.post('', :body => payload)
  end

end
