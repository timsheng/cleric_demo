require 'cleric/xml'
require 'data_magic'
class WechatPayload

  include Cleric::XML
  include DataMagic

  attr_accessor :payload

  def initialize key
    @payload = data_for key
  end

end
