require 'spec_helper'
require 'cleric/xml'

describe "Wechat" do
  include Cleric::XML
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
  let(:key) { key = @key }

  # just for example "how to use accessors methods in spec file"
  it "test accessor method" do
    wechat.lead
  end

  it "test example tag if can be fetched", :tag => 'Wechat1' do |example|
    response = wechat.send_text_message(payload.to_xml key)
    expect(response.code).to be(200)
  end

  context "Check Chatbot workflow." do
    let(:payload) { WechatPayload::Chatbot.payload key }

    it "New user send message to wechat will go into chatbot flow.", :tag => 'Wechat1' do |example|
      wechat.delete_user
      xml = to_xml(payload)
      response = wechat.send_text_message(xml)
      expect(response.code).to be(200)
      expect(response).to include("请问你的姓名是")
    end
  end

end
