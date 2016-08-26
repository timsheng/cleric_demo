require 'psych'

module Cleric
  module YAML

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
