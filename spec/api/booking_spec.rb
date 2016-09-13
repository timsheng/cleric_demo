require 'spec_helper'

describe 'Booking API testing' do
  before(:each) do
    puts "---do something needed before each example---"
  end

  after(:each) do
    puts "---do something needed after each example---"
  end

  it "get student info" do
    booking = Booking.new
    response = booking.get_student 'tim.sheng+9@student.com'
    expect(response.code).to be 200
  end

end
