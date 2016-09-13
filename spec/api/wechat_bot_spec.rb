require 'spec_helper'

describe "Wechat" do

  before(:all) do
    puts "starting wechat api testing"
  end

  after(:all) do
    puts "finished wechat api testing"
  end

  after(:each) do
    "close ssh port after each example"
    wechat.close_ssh wechat.port
  end

  let(:wechat) { Wechat.new(:ssh => 'Wechat_ssh', :db => 'Wechat_db') }

  # just for example "how to use accessors methods in spec file"
  it "test accessor method" do
    wechat.lead
  end

  it "test example tag if can be fetched", :tag => 'Wechat1' do |example|
    key = example.metadata[:tag]
    payload = WechatPayload.new(key)
    response = wechat.send_text_message(payload.to_xml)
    expect(response.code).to be(200)
  end

  context "Pre-condition sql execution" do
    it "select lead table before send text message to wechat",:prejob => 'Wechat1', :tag => 'Wechat1' do |example|
      key = example.metadata[:tag]
      payload = WechatPayload.new(key)
      response = wechat.send_text_message(payload.to_xml)
      expect(response.code).to be(200)
    end
  end

end
