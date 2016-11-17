require '../lib/cleric/box'

include Cleric::BOX

if ARGV.empty?
  puts "Please add a file name."
  exit
end

box = get_box ARGV[0]
plaintext = File.read(get_file ARGV[0])
ciphertext = box.encrypt(plaintext)
enc_file = get_file_enc ARGV[0]
File.write(enc_file, Base64.encode64(ciphertext))
