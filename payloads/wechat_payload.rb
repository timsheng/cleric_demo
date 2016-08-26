require 'cleric/xml'
class WechatPayload

  include Cleric::XML

  attr_accessor :toUserName, :fromUserName, :createTime, :msgType, :content, :msgId

  def initialize(&block)
    instance_eval &block if block_given?
  end

end
