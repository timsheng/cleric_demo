require 'spec_helper'

describe "Wechat" do

  before(:each) do
    puts "starting wechat api testing"
  end

  after(:each) do
    puts "finished wechat api testing"
  end

  # just for example "how to use accessors methods in spec file"
  # it "test accessor method" do
  #   wechat = Wechat.new
  #   wechat.lead
  #   wechat.ssh.close(wechat.port)
  # end
  #
  # it "test example tag if can be fetched", :tag => 'Wechat1' do |example|
  #   key = example.metadata[:tag]
  #   payload = WechatPayload.new(key)
  #   response = Wechat.send_text_message(payload.to_xml)
  #   puts response
  #   expect(response.code).to be(200)
  # end
  #
  # context "Pre-condition sql execution" do
  #   it "select lead table before send text message to wechat",:db => 'Wechat1', :tag => 'Wechat1' do |example|
  #     key = example.metadata[:tag]
  #     payload = WechatPayload.new(key)
  #     response = Wechat.send_text_message(payload.to_xml)
  #     puts response
  #     expect(response.code).to be(200)
  #   end
  # end

  describe "booking api demo" do
    it "call get student api successfully" do
      booking = Booking.new
      email = "tim.sheng+8@student.com"
      response = booking.get_student(email)
      expect(response.code).to be(200)
    end
  end

end
