require 'spec_helper'

describe "Wechat" do
  before(:all) do
    puts "---starting wechat api testing---"
  end

  after(:all) do
    puts "---finished wechat api testing---"
  end

  before(:each) do
    wechat.delete_account_binding(:open_id => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo')
    wechat.delete_lead(:from_user_name => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo')
    wechat.delete_session(:from_user_name => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo')
  end

  after(:each) do
    wechat.close_ssh wechat.port
  end

  let(:wechat) { Wechat.new(:ssh => 'Wechat_ssh', :db => 'Wechat_db') }
  let(:key) { key = @key }

  context "cleric methods demo" do
    it "test example tag if can be fetched", :key => 'Wechat1' do
      payload = WechatPayload.new
      response = wechat.send_text_message(payload.to_xml key)
      expect(response.code).to be(200)
    end

    context "Check Chatbot workflow." do
      let(:payload) { WechatPayload.new}
      it "New user send message to wechat will go into chatbot flow.", :key => 'Wechat1' do
        # sequel raw chained methods
        # wechat.db[:lead].filter(:from_user_name => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo').delete
        # wechat.delete_user(:from_user_name => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo')
        response = wechat.send_text_message(payload.to_xml key)
        expect(response.code).to be(200)
        expect(response).to include("请问你的姓名是")
      end

      it "New user send message to creat an enquiry on chatbot.", :key => 'Wechat3' do
        expect_result={'callbot' => '你的姓名是','name' => '你要去哪个国家呢','country' => '你要去哪个城市就读呢','city' => '你要去哪所学校就读呢','university' => '今年还是明年入住呢','move_in_year' => '你打算几月入住呢','move_in_month' => '你需要预订几个月呢','tenancy' => '留下你的邮箱','email' => '留下你的电话','phone' => 'success' }
        expect(wechat.db[:lead][:from_user_name => 'oTEVLv8uOrqOG3kukvEkmH04oMOw'].nil?).to be false
        for i in 0..expect_result.size - 1
          xml =  payload.to_xml(key,[expect_result.keys[i]])
          response = wechat.send_text_message(xml)
          expect(response.code).to be(200)
          expect(response).to include(expect_result.values[i])
        end
      end
    end

    context "new to_xml method example", :key => 'Wechat2' do
      it "support multiple questions for one case in yml" do
        payload = WechatPayload.new
        puts payload.to_xml(key)
        puts payload.to_xml(key,['1st'])
        puts payload.to_xml(key,['tier','2nd'])
      end
    end

    context "Pre-condition sql execution" do
      it "select lead table before send text message to wechat",:prejob => 'Wechat1', :key => 'Wechat1' do
        payload = WechatPayload.new
        response = wechat.send_text_message(payload.to_xml key)
      end
    end
  end

end
