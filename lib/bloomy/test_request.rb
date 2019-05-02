module Bloomy
  class TestRequest
    API_CODE = 5

    def initialize(api: 0, filter:, element:)
      @api = api
      @filter = filter
      @element = element
    end

    def encode
      [@api, API_CODE, @filter, " \t ", @element,  " \t ", "\r\n"].pack("L<L<a*a3a*a3a2")
    end

    def decode(response)
      response.unpack("L<a*")
    end
  end
end
