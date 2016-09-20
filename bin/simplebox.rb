require 'rbnacl'
require 'base64'

# key = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
# key.length = 32

def encrypt_message key
	box = RbNaCl::SimpleBox.from_secret_key(key)
	message = File.read("config/environments/stage.yml")
	puts message
	ciphertext = box.encrypt(message)
	File.w
	puts ciphertext
end

def decrypt_message key
	box = RbNaCl::SimpleBox.from_secret_key(key)
	ciphertext = box.decrypt(message)
	puts ciphertext
end


plaintext = box.decrypt(ciphertext)
puts plaintext