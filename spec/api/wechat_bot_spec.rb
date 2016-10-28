require 'spec_helper'

describe "Wechat" do
  before(:all) do
    puts "---starting wechat api testing---"
  end

  after(:all) do
    puts "---finished wechat api testing---"
  end

  before(:each) do
    session[:db].delete_account_binding(:open_id => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo')
    session[:db].delete_lead(:from_user_name => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo')
    session[:db].delete_session(:from_user_name => 'oTEVLvySMyYNIGW1iGPJq7ntTDOo')
  end

  after(:each) do
    session[:ssh].close_ssh session[:port]
  end

  let(:wechat) { Wechat.new }
  let(:pool) { Cleric::Pool.new }
  let(:session) { pool.use('Wechat_db','Wechat_ssh')}
  let(:key) { key = @key }

  context "Check Chatbot workflow." do
    let(:payload) { WechatPayload.payload key}

    it "New user send message to wechat will go into chatbot flow.", :key => 'Wechat1' do
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
        v['Content'] if k == 'email'
        response = wechat.send_text_message(v)
        expect(response.code).to be(200)
        expect(response).to include expect_result[index]
      end
    end

    it "New user scan QRcode on homepage can go to chatbot workflow.", :key => 'Wechat4' do
      expect_result = {'callbot' => '你的姓名是'}
      xml =  payload.to_xml(key,[expect_result.keys[0]])
      response = wechat.send_text_message(xml)
      expect(response.code).to be(200)
      expect(response).to include(expect_result.values[0])
    end

    it "New user tab menu to call BC can go to chatbot workflow.", :key => 'Wechat5' do
      expect_result = {'callbot' => '你的姓名是'}
      xml =  payload.to_xml(key,[expect_result.keys[0]])
      response = wechat.send_text_message(xml)
      expect(response.code).to be(200)
      expect(response).to include(expect_result.values[0])
    end

    it "Scan QRcode on manchester SRP page,chatbot will not ask to answer these two questions.", :key => 'Wechat6' do
      expect_result = {'callbot' => '你的姓名是','name' => '你要去哪所学校就读呢'}
      expect_result.each do |e|
        xml =  payload.to_xml(key,[e[0]])
        response = wechat.send_text_message(xml)
        expect(response.code).to be(200)
        expect(response).to include(e[1])
      end
    end

    it "New user send text message then scan QRcode will continue the last question.", :key => 'Wechat7' do
      expect_result = {'callbot1' => '你的姓名是','callbot2' => '请输入正确的中文姓名'}
      expect_result.each do |e|
        xml =  payload.to_xml(key,[e[0]])
        response = wechat.send_text_message(xml)
        expect(response.code).to be(200)
        expect(response).to include(e[1])
      end
    end

    it "Answer more than three times wrong answer can go to grata straightly.", :key => 'Wechat8' do
      expect_result = {'callbot' => '你的姓名是','name1' => '请输入正确的中文姓名','name2' => '请输入正确的中文姓名','name3' => '转人工服务','callbc' => 'success'}
      expect_result.each do |e|
        xml =  payload.to_xml(key,[e[0]])
        response = wechat.send_text_message(xml)
        expect(response.code).to be(200)
        expect(response).to include(e[1])
      end
    end

    it "Error message testing of all the questiongs when answer is not correct.", :key => 'Wechat9' do
      expect_result = {'callbot' => '你的姓名是','name1' => '请输入正确的中文姓名','name2' => '你要去哪个国家呢','country1' => '请输入国家的中文或英文名','country2' => '你要去哪个城市就读呢','city1' => '请输入城市的中文或英文名','city2' => '你要去哪所学校就读呢','university1' => '请输入学校名','university2' => '今年还是明年入住呢','move_in_year1' => '请选择正确的入住年份','move_in_year2' => '你打算几月入住呢','move_in_month1' => '请选择正确的入住月份','move_in_month2' => '你需要预订几个月呢','tenancy1' => '请选择正确的预订周期','tenancy2' => '留下你的邮箱','email1' => '请输入正确的邮箱','email2' => '留下你的电话','phone' => '请输入正确的手机号码'}
      expect_result.each do |e|
        xml =  payload.to_xml(key,[e[0]])
        response = wechat.send_text_message(xml)
        expect(response.code).to be(200)
        expect(response).to include(e[1])
      end
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
