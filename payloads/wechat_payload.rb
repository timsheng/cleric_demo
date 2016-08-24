require 'xml_helper'
class WechatPayload

  include Helper::XML

  attr_accessor :toUserName, :fromUserName, :createTime, :msgType, :content, :msgId

  def initialize(&block)
    instance_eval &block if block_given?
  end

end
