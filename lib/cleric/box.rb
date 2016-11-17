require 'rbnacl'
require 'base64'

module Cleric
	module BOX
		def get_box env
			file = "../config/environments/#{env}.yml"
			file_enc = "../config/environments/#{env}.yml.enc"
			key_env = ENV['CLERIC_ENCRYPT']
			if key_env.nil?
				puts "Please add env parameter CLERIC_ENCRYPT..."
				return
			end
			key = Base64.decode64(key_env)
			RbNaCl::SimpleBox.from_secret_key(key)
		end

		def get_file env
			file = "../config/environments/#{env}.yml"
		end

		def get_file_enc env
			file_enc = "../config/environments/#{env}.yml.enc"
		end
	end
end
