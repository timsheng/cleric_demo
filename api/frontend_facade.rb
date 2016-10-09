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

  def get_cities_of_a_given_country country_slug, locale, sort = nil
    self.class.headers({'Accept-Language' => locale})
    if sort == nil
      self.class.get("/cities?country_slug=#{country_slug}")
    else
      self.class.get("/cities?country_slug=#{country_slug}&sort=#{sort}")
    end
  end

  def get_list_of_countries locale, sort = nil
    self.class.headers({'Accept-Language' => locale})
    if sort == nil
      self.class.get("/countries")
    else
      self.class.get("/countries?sort=#{sort}")
    end
  end

  def expect_result key
    DataMagic.load 'frontendfacade.yml'
    data_for(key)['response']
  end
end
