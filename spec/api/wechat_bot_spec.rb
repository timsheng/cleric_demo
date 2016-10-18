require 'spec_helper'

describe "Wechat" do
  before(:all) do
    puts "---starting wechat api testing---"
  end

  after(:all) do
    puts "---finished wechat api testing---"
  end

  # after(:each) do
  #   wechat.close_ssh wechat.port
  # end

  let(:wechat) { Wechat.new(:ssh => 'Wechat_ssh', :db => 'Wechat_db') }
  let(:key) { key = @key }

  context "cleric methods demo" do
    # just for example "how to use accessors methods in spec file"
    # it "test accessor method" do
    #   wechat.lead
    # end

    # it "test example tag if can be fetched", :key => 'Wechat1' do
    #   payload = WechatPayload.new
    #   response = wechat.send_text_message(payload.to_xml key)
    #   expect(response.code).to be(200)
    # end

    # context "Check Chatbot workflow." do
    #   let(:payload) { WechatPayload.new}
    #
    #   it "New user send message to wechat will go into chatbot flow.", :tag => 'Wechat1' do |example|
    #     wechat.delete_user
    #     xml = payload.to_xml key
    #     response = wechat.send_text_message(xml)
    #     expect(response.code).to be(200)
    #     expect(response).to include("请问你的姓名是")
    #   end
    # end

    # context "Pre-condition sql execution" do
    #   it "select lead table before send text message to wechat",:prejob => 'Wechat1', :key => 'Wechat1' do |example|
    #     payload = WechatPayload.new
    #     response = wechat.send_text_message(payload.to_xml key)
    #   end
    # end
  end

end
