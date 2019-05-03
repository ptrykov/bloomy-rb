module Bloomy
  class Connection
    CONNECT_TIMEOUT = 10
    SOCKET_TIMEOUT = 10

    def initialize(host, port, connect_timeout: , socket_timeout:)
      @host = host
      @port = port
      @connect_timeout = connect_timeout || CONNECT_TIMEOUT
      @socket_timeout = socket_timeout || SOCKET_TIMEOUT
      open
    end

    def open
      @socket = SocketWithTimeout.new(@host, @port, connect_timeout: @connect_timeout, timeout: @socket_timeout)
    end

    def close
      @socket.close if @socket
    end

    def send_request(request)
      @socket.write(request.encode)
    end

    def wait_for_response
     p @socket.read
    end
  end
end
