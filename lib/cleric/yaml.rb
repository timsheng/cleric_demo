require 'psych'

module Cleric
  module YAML

    CONFIGURE_PATH = "config/environments/stage.yml"

    def fetch_corresponding_configure_value name
      all_hash_values = load_yml(CONFIGURE_PATH)
      conf_value = fetch_value_by_key all_hash_values, name
    end

    def load_yml path
      Psych.load_file(path)
    end

    def fetch_value_by_key hash, key
      if hash[key].nil?
        fail "can not find corresponding configure value for #{key}"
      else
        hash[key]
      end
    end

  end
end
