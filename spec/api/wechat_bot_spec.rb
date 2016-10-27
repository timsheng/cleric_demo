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

  context "Check Chatbot workflow." do
    let(:payload) { WechatPayload.payload key}

    it "New user send message to wechat will go into chatbot flow.", :key => 'Wechat1' do
      # sequel raw chained methods
      # wechat.db[:lead].filter(:from_user_name => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo').delete
      # wechat.delete_user(:from_user_name => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo')
      response = wechat.send_text_message(payload)
      expect(response.code).to be(200)
      expect(response).to include("请问你的姓名是")
    end

    it "New user send message to creat an enquiry on chatbot.", :key => 'Wechat3' do
      expect_result = [
        '你的姓名是',
        '你要去哪个国家呢',
        '你要去哪个城市就读呢',
        '你要去哪所学校就读呢',
        '今年还是明年入住呢',
        '你打算几月入住呢',
        '你需要预订几个月呢',
        '留下你的邮箱',
        '留下你的电话',
        'success',
        'success'
      ]
      payload.each_with_index do |(k, v), index|
        @enquiry_email = v['Content'] if k == 'email'
        response = wechat.send_text_message(v)
        expect(response.code).to be(200)
        expect(response).to include expect_result[index]
      end
      expect(wechat.db[:enquiry][:email => @enquiry_email]).not_to be nil
      expect(wechat.db[:session][:from_user_name => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo'][:forward_to]).to eql 2
    end

    it "New user scan QRcode on homepage can go to chatbot workflow.", :key => 'Wechat4' do
      expect_result = '你的姓名是'
      response = wechat.send_text_message(payload)
      expect(response.code).to be(200)
      expect(response).to include(expect_result)
    end

    it "New user tab menu to call BC can go to chatbot workflow.", :key => 'Wechat5' do
      expect_result = '你的姓名是'
      response = wechat.send_text_message(payload)
      expect(response.code).to be(200)
      expect(response).to include(expect_result)
    end

    it "Scan QRcode on manchester SRP page,chatbot will not ask to answer these two questions.", :key => 'Wechat6' do
      expect_result = ['你的姓名是','你要去哪所学校就读呢']
      payload.each_with_index do |(k, v), index|
        response = wechat.send_text_message(v)
        expect(response.code).to be(200)
        expect(response).to include expect_result[index]
      end
    end

    it "New user send text message then scan QRcode will continue the last question.", :key => 'Wechat7' do
      expect_result = ['你的姓名是','请输入正确的中文姓名']
      payload.each_with_index do |(k, v), index|
        response = wechat.send_text_message(v)
        expect(response.code).to be(200)
        expect(response).to include expect_result[index]
      end
    end

    it "Answer more than three times wrong answer can go to grata straightly.", :key => 'Wechat8' do
      expect_result = [
        '你的姓名是',
        '请输入正确的中文姓名',
        '请输入正确的中文姓名',
        '转人工服务',
        'success'
      ]
      payload.each_with_index do |(k, v), index|
        response = wechat.send_text_message(v)
        expect(response.code).to be(200)
        expect(response).to include expect_result[index]
      end
    end

    it "Error message testing of all the questiongs when answer is not correct.", :key => 'Wechat9' do
      expect_result = [
        '你的姓名是',
        '请输入正确的中文姓名',
        '你要去哪个国家呢',
        '请输入国家的中文或英文名',
        '你要去哪个城市就读呢',
        '请输入城市的中文或英文名',
        '你要去哪所学校就读呢',
        '请输入学校名',
        '今年还是明年入住呢',
        '请选择正确的入住年份',
        '你打算几月入住呢',
        '请选择正确的入住月份',
        '你需要预订几个月呢',
        '请选择正确的预订周期',
        '留下你的邮箱',
        '请输入正确的邮箱',
        '留下你的电话',
        '请输入正确的手机号码'
      ]
      payload.each_with_index do |(k, v), index|
        response = wechat.send_text_message(v)
        expect(response.code).to be(200)
        expect(response).to include expect_result[index]
      end
    end

    it "Using existing enquiry email 'dolores.zhang+0@student.com' to submit on chatbot in same city 'sidney' won't create new enquiry.", :key => 'Wechat10' do
      wechat.db[:enquiry].filter(:email => 'dolores.zhang+0@student.com').delete
      expect_result = [
        '你的姓名是',
        '你要去哪所学校就读呢',
        '今年还是明年入住呢',
        '你打算几月入住呢',
        '你需要预订几个月呢',
        '留下你的邮箱',
        '留下你的电话',
        'success',
      ]
      payload.each_with_index do |(k, v), index|
        response = wechat.send_text_message(v)
        expect(response.code).to be(200)
        expect(response).to include expect_result[index]
      end
      expect(wechat.db[:enquiry][:email => 'dolores.zhang+0@student.com'][:enquiry_id]).to eql 93005
    end

    it "User scan QRcode with log in account and with one open enquiry will combine successfully and forward to qiyu.", :key => 'Wechat11' do
      response = wechat.send_text_message(payload)
      expect(response.code).to be(200)
      expect(wechat.db[:account_binding][:open_id => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo'][:email]).to eql 'dolores.zhang+0@student.com'
      expect(wechat.db[:session][:from_user_name => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo'][:forward_to]).to eql 2
    end

    it "User scan QRcode whose account is log in and have no open enquiry will go to chatbot workflow.", :key => 'Wechat12' do
      expect_result = '你的姓名是'
      response = wechat.send_text_message(payload)
      expect(response.code).to be(200)
      expect(wechat.db[:account_binding][:open_id => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo'][:email]).to eql 'dolores.zhang+00@student.com'
      expect(response).to include(expect_result)
    end

  end

  context "Pre-condition sql execution" do
    it "select lead table before send text message to wechat",:prejob => 'Wechat1', :key => 'Wechat1' do
      payload = WechatPayload.new
      response = wechat.send_text_message(payload.to_xml key)
    end
  end

end

describe "test demo" do
  context "cleric methods demo" do
    it "test example tag if can be fetched", :key => 'Wechat1' do
      payload = WechatPayload.payload key
      response = wechat.send_text_message(payload)
      expect(response.code).to be(200)
    end
  end
end
