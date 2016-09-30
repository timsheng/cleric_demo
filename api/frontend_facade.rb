require './api/api'
require './lib/cleric'

class FrontendFacade < API

  debug_output $stdout

  base_uri http('base_uri')

  def create_user payload
    self.class.post('/users', :body => payload.to_json)
  end

  def get_summary_for_a_property property_slug,locale
    self.class.headers({'Accept-Language' => locale})
    self.class.get("/properties/#{property_slug}/summary")
  end
end
