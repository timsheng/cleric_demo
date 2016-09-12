require './api/api'
require './lib/cleric'

class Booking < API

  debug_output $stdout

  base_uri http('base_uri')

  basic_auth http('basic_auth','user'), http('basic_auth','password')

  headers http('headers')

  def get_student email
    path = "/api/v3/student/#{email}"
    self.class.headers generate_token(path)
    self.class.get path
  end

  def generate_token(payload)
    shared_secret = self.class.http('shared_secret')
    token = Base64.encode64(OpenSSL::HMAC.digest('sha1', shared_secret, payload))
    return {'X-OSL-TOKEN' => token}
  end

end
