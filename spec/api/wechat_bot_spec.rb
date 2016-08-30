require 'spec_helper'

describe "Wechat" do

  before(:each) do
    puts "starting wechat api testing"
  end

  after(:each) do
    puts "finished wechat api testing"
  end

  # it "POST /wechat should return a 200" do
  #
  #   payload = WechatPayload.new do
  #     self.toUserName = 'gh_0d6f2db688b4'
  #     self.fromUserName = 'oTEVLvyCMbI9hHLu1lpDFk4Y791s'
  #     self.createTime = "#{Time.now}"
  #     self.msgType = 'text'
  #     self.content = '伦敦'
  #     self.msgId = "#{rand(100000000)}"
  #   end
  #
  #   response = Wechat.send_text_message(payload.to_xml)
  #   puts response
  #   expect(response.code).to be(200)
  #
  # end

  # just for example "how to use accessors methods in spec file"
  it "test accessor method" do
    wechat = Wechat.new
    wechat.lead
  end

  it "test example tag if can be fetched", :tag => 'Wechat1' do |example|
    key = example.metadata[:tag]
    payload = WechatPayload.new(key)
    response = Wechat.send_text_message(payload.to_xml)
    puts response
    expect(response.code).to be(200)
  end

end
