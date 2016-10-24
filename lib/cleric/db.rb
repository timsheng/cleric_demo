require 'mysql2'
require 'sequel'

module Cleric
  module DB

    def connect_database name, port=false
      db_conf = Cleric::YAML.fetch_corresponding_conf_by name
      db_conf = db_conf.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      db_conf = db_conf.merge(:port => port) if port
      # puts "connect #{name} database"
      @db = get_ready_for_database db_conf
    end

    def get_ready_for_database conf
      begin
        Sequel.connect(conf)
      rescue
        fail "database configuration \n #{conf} \n is not correct, please double check"
      end
    end

  end
end
