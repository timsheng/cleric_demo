require './api/api'

class FrontendFacade < API

  base_uri http('base_uri')

  query :id, :db => 'properties',:name => '1 Penta House'
  query :name, :db => 'properties', :id => 1
  query :address, :db => 'properties', :id => 1

  def create_user payload
    self.class.post('/users', :body => payload.to_json)
  end

  def get_summary_for_a_property property_slug, locale
    self.class.headers({'Accept-Language' => locale})
    self.class.get("/properties/#{property_slug}/summary")
  end

  def get_areas_of_a_given_city city_slug, locale, sort = nil
    self.class.headers({'Accept-Language' => locale})
    if sort == nil
      self.class.get("/areas?city_slug=#{city_slug}")
    else
      self.class.get("/areas?city_slug=#{city_slug}&sort=#{sort}")
    end
  end

  def expect_result key
    DataMagic.load 'frontendfacade.yml'
    data_for(key)['response']
  end
end
