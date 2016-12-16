require './payloads/payload'

module FrontendFacadePayload
  module Property
    class Summary < Payload
    end

    class Users < Payload
    end

    class Rooms < Payload
    end
  end

  module Locations
    class Countries < Payload
    end

    class Cities < Payload
    end

    class City < Payload
    end

    class Areas < Payload
    end

    class Area < Payload
    end
  end

  module Universities
    class Details < Payload
    end

    class List < Payload
    end
  end

  module Users
    class Login < Payload
    end

    class Signup < Payload
    end

    class SetPassword < Payload
    end

    class User < Payload
    end
  end

  module Enquiry
    class CreateEnquiry < Payload
    end
  end

  module Students
    class StudentInfo < Payload
    end

    class StudentRecords < Payload
    end
  end
end
