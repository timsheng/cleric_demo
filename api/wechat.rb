require './api/api'

class Wechat < API

  include Cleric::Accessors

  base_uri http('base_uri')

  # just for example "how to use method in accessors"
  count_table :lead
  delete_user_query :delete_user, :db => 'lead',:from_user_name => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo'
  # end

  def send_text_message payload
    self.class.post('', :body => payload)
  end

end
