require './api/api'

class FrontendFacade < API

  base_uri http('base_uri')
  column :booking_student, :table => 'student'
  column :identity_user, :table => 'user'

  def create_user payload
    self.class.post('/users', :body => payload.to_json)
  end

  def user_signup payload
    add_headers({'Content-Type' => "application/json"})
    response = self.class.post('/users/sign-up', :body => payload.to_json, :headers => new_headers)
    return new_response(response)
  end

  def user_login payload
    add_headers({'Content-Type' => "application/json"})
    response = self.class.post('/users/login', :body => payload.to_json, :headers => new_headers)
    return new_response(response)
  end

  def user_forgot_password payload, language = false
    add_headers({'Content-Type' => "application/json"})
    add_headers({'Accept-Language' => language}) if language
    response = self.class.post('/users/forgot-password', :body => payload.to_json, :headers => new_headers)
    return new_response(response)
  end

  def check_user_exist payload
    add_headers({'Content-Type' => "application/json"})
    response = self.class.post('/users/check', :body => payload.to_json, :headers => new_headers)
    return new_response(response)
  end

  def user_set_password payload, token = false
    add_headers({'Content-Type' => "application/json"})
    add_headers({'Authorization' => "Bearer #{token}"}) if token
    response = self.class.post('/users/set-password', :body => payload.to_json, :headers => new_headers )
    return new_response(response)
  end

  def create_enquiry payload, token = false
    add_headers({'Content-Type' => "application/json"})
    add_headers({'Authorization' => "Bearer #{token}"}) if token
    response = self.class.post('/enquiry', :body => payload.to_json, :headers => new_headers)
    return new_response(response)
  end

  def get_summary_for_a_property property_slug, locale
    add_headers({'Accept-Language' => locale})
    response = self.class.get("/properties/#{property_slug}/summary", :headers => new_headers)
    return new_response(response)
  end

  def get_rooms_for_a_property property_slug
    response = self.class.get("/properties/#{property_slug}/rooms")
    return new_response(response)
  end

  def get_details_of_a_given_university university, locale
    add_headers({'Accept-Language' => locale})
    response = self.class.get("/universities/#{university}", :headers => new_headers)
    return new_response(response)
  end

  def get_details_of_an_area area_slug, locale
    add_headers({'Accept-Language' => locale})
    response = self.class.get("/areas/#{area_slug}", :headers => new_headers)
    return new_response(response)
  end

  def get_areas_of_a_given_city city_slug, locale, sort = nil
    add_headers({'Accept-Language' => locale})
    if sort == nil
      response = self.class.get("/areas?city_slug=#{city_slug}", :headers => new_headers)
    else
      response = self.class.get("/areas?city_slug=#{city_slug}&sort=#{sort}", :headers => new_headers)
    end
    return new_response(response)
  end

  def get_details_of_a_city city_slug, locale
    add_headers({'Accept-Language' => locale})
    response = self.class.get("/cities/#{city_slug}", :headers => new_headers)
    return new_response(response)
  end

  def get_cities_of_a_given_country country_slug, locale, sort = nil
    add_headers({'Accept-Language' => locale})
    if sort == nil
      response = self.class.get("/cities?country_slug=#{country_slug}", :headers => new_headers)
    else
      response = self.class.get("/cities?country_slug=#{country_slug}&sort=#{sort}", :headers => new_headers)
    end
    return new_response(response)
  end

  def get_list_of_countries locale, sort = nil
    add_headers({'Accept-Language' => locale})
    if sort == nil
      response = self.class.get("/countries", :headers => new_headers)
    else
      response = self.class.get("/countries?sort=#{sort}", :headers => new_headers)
    end
    return new_response(response)
  end

  def get_list_of_universities country_slug, city_slug, locale, sort = nil
    add_headers({'Accept-Language' => locale})
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
    response = self.class.get(url[0, url.length - 1], :headers => new_headers)
    return new_response(response)
  end

  def expect_result key
    DataMagic.load 'frontendfacade.yml'
    data_for(key)['response']
  end

end
