require 'rbnacl'
require 'base64'

module Cleric
	def get_box
		file = "../config/environments/stage.yml"
		file_enc = "../config/environments/stage.yml.enc"
		key_env = ENV['KEY_ENV']
		key = Base64.decode64(key_env)
		RbNaCl::SimpleBox.from_secret_key(key)
	end

	def get_file
		file = "../config/environments/stage.yml"
	end

	def get_file_enc
		file_enc = "../config/environments/stage.yml.enc"
	end
end
