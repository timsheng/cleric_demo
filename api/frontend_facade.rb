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
    response = self.class.get("/properties/#{property_slug}/summary")
    return new_response(response)
  end

  def get_rooms_for_a_property property_slug
    response = self.class.get("/properties/#{property_slug}/rooms")
    return new_response(response)
  end

  def get_details_of_a_given_university university, locale
    self.class.headers({'Accept-Language' => locale})
    response = self.class.get("/universities/#{university}")
    return new_response(response)
  end

  def get_details_of_an_area area_slug, locale
    self.class.headers({'Accept-Language' => locale})
    response = self.class.get("/areas/#{area_slug}")
    return new_response(response)
  end

  def get_areas_of_a_given_city city_slug, locale, sort = nil
    self.class.headers({'Accept-Language' => locale})
    if sort == nil
      response = self.class.get("/areas?city_slug=#{city_slug}")
    else
      response = self.class.get("/areas?city_slug=#{city_slug}&sort=#{sort}")
    end
    return new_response(response)
  end

  def get_details_of_a_city city_slug, locale
    self.class.headers({'Accept-Language' => locale})
    response = self.class.get("/cities/#{city_slug}")
    return new_response(response)
  end

  def get_cities_of_a_given_country country_slug, locale, sort = nil
    self.class.headers({'Accept-Language' => locale})
    if sort == nil
      response = self.class.get("/cities?country_slug=#{country_slug}")
    else
      response = self.class.get("/cities?country_slug=#{country_slug}&sort=#{sort}")
    end
    return new_response(response)
  end

  def get_list_of_countries locale, sort = nil
    self.class.headers({'Accept-Language' => locale})
    if sort == nil
      response = self.class.get("/countries")
    else
      response = self.class.get("/countries?sort=#{sort}")
    end
    return new_response(response)
  end

  def get_list_of_universities country_slug, city_slug, locale, sort = nil
    self.class.headers({'Accept-Language' => locale})
    url = "/universities?"
    if country_slug != nil
      url = url + "country_slug=" + country_slug + "&"
    end
    if city_slug != nil
      url = url + "city_slug=" + city_slug + "&"
    end
    if sort != nil
      url = url + "sort=" + sort + "&"
    end
    response = self.class.get(url[0, url.length - 1])
    return new_response(response)
  end

  def expect_result key
    DataMagic.load 'frontendfacade.yml'
    data_for(key)['response']
  end
end
