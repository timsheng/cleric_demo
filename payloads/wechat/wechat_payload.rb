require 'cleric/xml'
require './payloads/payload'

module WechatPayload

  class Chatbot < Payload
    include Cleric::XML
  end

end
