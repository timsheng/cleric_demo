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
end
