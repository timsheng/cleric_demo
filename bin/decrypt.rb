require '../lib/cleric/box'

include Cleric::BOX

if ARGV.empty?
  puts "Please add a file name."
  exit
end

box = get_box ARGV[0]
ciphertext = File.read(get_file_enc ARGV[0])
plaintext = box.decrypt(Base64.decode64(ciphertext))
plain_file = get_file ARGV[0]
File.write(plain_file, plaintext)
