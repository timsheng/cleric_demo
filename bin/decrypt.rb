require 'rbnacl'
require 'base64'
require '../lib/cleric/box'

include Cleric

box = get_box
ciphertext = File.read(get_file_enc)
plaintext = box.decrypt(Base64.decode64(ciphertext))
File.write(get_file, plaintext)
