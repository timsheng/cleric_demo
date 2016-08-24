require 'mysql2'
require 'sequel'

module Helper
  module DB

    DB_CONFIGURE_PATH = "config/database.yml"

    def fetch_corresponding_db_configure_value name
      all_hash_values = load_yml(DB_CONFIGURE_PATH)
      conf_value = fetch_value_by_key all_hash_values, name
    end

    def connect_database name ,port
      puts "connect #{name} database via #{port}"
      conf_value = fetch_corresponding_db_configure_value name
      conf_value = conf_value.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      conf_value = conf_value.merge(:port => port)
      get_ready_for_database conf_value
    end

    def get_ready_for_database conf
      Sequel.connect(conf)
    end

  end
end
