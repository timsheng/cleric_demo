require 'brnacl'

path = "../config/environments/"
key = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
puts key
box = RbNaCl::SimpleBox.from_secret_key(key)
plaintext = File.read(path + "stage.yml")
puts plaintext
ciphertext = box.encrypt(plaintext)
puts ciphertext
File.write(path + "stage.yml.enc", ciphertext)
