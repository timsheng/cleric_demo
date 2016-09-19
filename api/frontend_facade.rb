require './api/api'
require './lib/cleric'

class FrontendFacade < API

  debug_output $stdout

  base_uri http('base_uri')

  def create_user payload
    self.class.post('/users', :body => payload.to_json)
  end

end
