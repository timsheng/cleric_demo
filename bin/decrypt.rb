require 'rbnacl'
require 'base64'

file = "../config/environments/stage.yml"
file_enc = "../config/environments/stage.yml.enc"

key_env = ENV['KEY_ENV']
key = Base64.decode64(key_env)
box = RbNaCl::SimpleBox.from_secret_key(key)
ciphertext = File.read(file_enc)
plaintext = box.decrypt(Base64.decode64(ciphertext))
File.write(file, plaintext)