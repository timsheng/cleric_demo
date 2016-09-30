require 'spec_helper'

describe "Frontend Facade" do

  let(:frontend_facade) {FrontendFacade.new()}

  describe "Users" do
    it "should create user", :tag => 'Users1' do |example|
      key = example.metadata[:tag]
      frontend_facade_payload = FrontendFacadePayload.new(key)
      puts frontend_facade_payload.payload
      response = frontend_facade.create_user(frontend_facade_payload.payload)
      expect(response.code).to be(200)
    end
  end

  describe 'Property' do
    context "Property summary" do

      it "get summary for a property for en-gb", :tag => 'student_villiage_summary_en' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_summary_for_a_property('student-village','en-gb')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to eq(expected)
      end

      it "get summary for a property for zh-cn", :tag => 'student_villiage_summary_cn' do |example|
        key = example.metadata[:tag]
        frontend_facade_payload = FrontendFacadePayload.new(key)
        expected = frontend_facade_payload.payload
        response = frontend_facade.get_summary_for_a_property('student-village','zh-cn')
        result = response.parsed_response
        expect(response.code).to be(200)
        expect(result).to eq(expected)
      end

    context "Get Property" do
      it "dbfactory demo" ,:tag => 'Users2' do |example|
        key = example.metadata[:tag]
        frontend_facade = FrontendFacade.new(:ssh => 'Property_ssh', :db => 'Property_db')
        # puts frontend_facade.id
        # puts frontend_facade.name
        # puts frontend_facade.address
        puts frontend_facade.expect_result(key)
      end
  end
end
