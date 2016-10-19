require 'rspec'
require './api/wechat'
require './api/booking'
require './api/frontend_facade'
require './payloads/wechat/wechat_payload'
require './payloads/facade/frontend_facade_payload'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }

class PreJob

  include DataMagic

  def initialize name
    DataMagic.load 'prejob.yml'
    @actions = data_for(name)
  end

  def handle
    action_types =  @actions.keys
    action_types.each do |type|
      case type
      when 'helper'
        actions = @actions['helper']
        actions.each do |k, v|
          api = Object.const_get(k).new
          puts "#{api} says #{v}"
        end
      when 'db'
        actions = @actions['db']
        actions.each do |k, v|
          api = Object.const_get(k).new(:ssh => "#{k}_ssh", :db => "#{k}_db")
          if api.respond_to?(v)
            api.send v
          else
            api.db[v].count
          end
          api.close_ssh(api.port)
        end
      end
    end

  end


end

RSpec.configure do |c|
  c.around(:example) do |example|
    if example.metadata.has_key?(:prejob)
      prejob =  example.metadata[:prejob]
      pj = PreJob.new(prejob)
      pj.handle
    end
    @key = example.metadata[:key]
    @params = example.metadata[:params]
    example.run
  end
end
