require 'spec_helper'

describe "Frontend Facade" do
  before(:all) do
    puts "starting frontend facade users test cases"
  end
  context "Users" do
    it "should create user", :tag => 'Users1' do |example|
      key = example.metadata[:tag]
      frontend_facade_payload = FrontendFacadePayload.new(key)
      puts frontend_facade_payload.payload
      frontend_facade = FrontendFacade.new
      response = frontend_facade.create_user(frontend_facade_payload.payload)
      expect(response.code).to be(200)
    end
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
