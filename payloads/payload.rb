require 'data_magic'

class Payload

  include DataMagic

  attr_accessor :payload

  def initialize key
    DataMagic.load filename
    @payload = data_for(key)['payload']
  end

  private

  def filename
    current_class = self.class.to_s
    current_class.slice! "Payload"
    file_name = current_class.downcase!
    return file_name + '.yml'
  end

end
