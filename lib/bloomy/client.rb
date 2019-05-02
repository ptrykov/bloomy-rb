module Bloomy
  class Client
    # connection
    # send_request => response

    def initialize

    end

    # TODO: this is not thread safe
    def send_request(request)
      connection.send_request(request)
      connection.wait_for_response
    rescue Exception
      connection.close rescue nil
      @connection = nil
      raise
    end

    private

    def connection
      @connection ||= Connection.new('localhost', 3333, connect_timeout: 5, socket_timeout: 5)
    end
  end
end
