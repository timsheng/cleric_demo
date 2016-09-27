require './api/api'
require './lib/cleric'

class FrontendFacade < API

  debug_output $stdout

  base_uri http('base_uri')

  query :id, :db => 'properties',:name => '1 Penta House'
  query :name, :db => 'properties', :id => 1
  query :address, :db => 'properties', :id => 1

  def create_user payload
    self.class.post('/users', :body => payload.to_json)
  end

  def expect_result key
    DataMagic.load 'frontendfacade.yml'
    data_for(key)['response']
  end




end
