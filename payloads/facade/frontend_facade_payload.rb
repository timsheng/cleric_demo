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

  module University
    class Details < Payload
    end

  end
end
