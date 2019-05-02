module Bloomy
  class Filter
    def initialize(name)
      @name = name
    end

    def includes?(element)
      client.send_request(TestRequest.new(filter: @name, element: element))
    end

    def client
      @client ||= Client.new
    end
  end
end
