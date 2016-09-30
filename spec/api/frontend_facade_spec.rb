require 'spec_helper'

describe "Frontend Facade" do

  before(:all) do
    puts "starting frontend facade test cases"
  end

  let(:frontend_facade) {FrontendFacade.new()}

  context "Users" do
    it "should create user", :tag => 'User1' do |example|
      key = example.metadata[:tag]
      frontend_facade_payload = FrontendFacadePayload.new(key)
      puts frontend_facade_payload.payload
      response = frontend_facade.create_user(frontend_facade_payload.payload)
      expect(response.code).to be(200)
    end
  end

  context "Property" do

    it "check get summary for a property for en-gb", :tag => 'student_villiage_summary_en' do |example|
      key = example.metadata[:tag]
      frontend_facade_payload = FrontendFacadePayload.new(key)
      expected = frontend_facade_payload.payload
      response = frontend_facade.get_summary_for_a_property('student-village','en-gb')
      result = response.parsed_response
      expect(response.code).to be(200)
      expect(result).to eq(expected)
    end

    it "check get summary for a property for zh-cn", :tag => 'student_villiage_summary_cn' do |example|
      key = example.metadata[:tag]
      frontend_facade_payload = FrontendFacadePayload.new(key)
      expected = frontend_facade_payload.payload
      response = frontend_facade.get_summary_for_a_property('student-village','zh-cn')
      result = response.parsed_response
      expect(response.code).to be(200)
      expect(result).to eq(expected)
    end
  end
end
