# # require 'psych'
# require 'yaml'
# module HTTP
#   include YAML
#   CONFIGURE_PATH = "config/environments/#{ENV['PLATFORM']}.yml"
#
#   def fetch_corresponding_configure_value name
#     all_hash_values = load_yml(CONFIGURE_PATH)
#     conf_value = fetch_value_by_key all_hash_values, name
#   end
#
#   def load_yml path
#     Psych.load_file(path)
#   end
#
#   def fetch_value_by_key hash, key
#     begin
#       if hash[key].nil?
#         fail "can not find corresponding configure value for #{key}"
#       else
#         hash[key]
#       end
#     rescue
#       raise  "no configuration in #{ENV['PLATFORM']}.yml"
#     end
#   end
#
#   def fetch_http_config key
#     conf_value = fetch_corresponding_configure_value key
#     http = {}
#     http[:base_uri] = conf_value['base_uri'] if conf_value['base_uri']
#     http[:basic_auth] = conf_value['basic_auth'] if conf_value['basic_auth']
#     http[:headers] = conf_value['headers'] if conf_value['headers']
#     http
#   end
#
#   alias_method :http, :fetch_http_config
# end
