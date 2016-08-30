require 'mysql2'
require 'sequel'

module Cleric
  module DB

    def connect_database name ,port
      puts "connect #{name} database via #{port}"
      conf_value = fetch_corresponding_configure_value name
      conf_value = conf_value.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      conf_value = conf_value.merge(:port => port)
      get_ready_for_database conf_value
    end

    def get_ready_for_database conf
      Sequel.connect(conf)
    end

  end
end
