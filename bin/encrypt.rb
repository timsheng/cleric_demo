require '../lib/cleric/box'

include Cleric::BOX

box = get_box
plaintext = File.read(get_file)
ciphertext = box.encrypt(plaintext)
File.write(get_file_enc, Base64.encode64(ciphertext))
