require 'rbnacl'
require 'base64'
require '../lib/cleric/box'

include Cleric

box = get_box
plaintext = File.read(get_file)
ciphertext = box.encrypt(plaintext)
File.write(get_file_enc, Base64.encode64(ciphertext))
