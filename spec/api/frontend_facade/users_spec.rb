require 'spec_helper'

describe "Frontend Facade > Users" do
  before(:all) do
    puts "starting frontend facade users test cases"
  end
  it "should create user", :tag => 'Users1' do |example|
    key = example.metadata[:tag]
    users_payload = UsersPayload.new(key)
    puts users_payload.payload
    users = Users.new
    response = users.create_user(users_payload.payload)
    expect(response.code).to be(200)
  end
end
