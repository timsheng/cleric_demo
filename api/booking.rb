require 'httparty'
require './lib/cleric'

class Booking
  include HTTParty
  include Cleric

  base_uri 'https://bookings.stage.overseasstudentliving.com/api/v3/student'

  basic_auth 'oslqa', 'm2WackNUHbAqHz51'

  headers_value = {
    'Content-type' =>  "application/json",
    'X-OSL-PKEY' => "32489878329jkkkjh3k4j2hjk324k",
    'X-OSL-TOKEN'=> "Aq5LNXQUTDUrpg0Tx6yPcpA57XE="
  }

  headers headers_value
  
  def get_student email
    self.class.get "/#{email}"
  end

end
