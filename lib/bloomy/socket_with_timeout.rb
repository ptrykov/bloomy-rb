require 'socket'

module Bloomy
  class SocketWithTimeout
    def initialize(host, port, connect_timeout: 5, timeout: 5)
      addr = Socket.getaddrinfo(host, nil)
      sockaddr = Socket.pack_sockaddr_in(port, addr[0][3])
      @socket = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)
      @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      @timeout = timeout

      begin
        # Initiate the socket connection in the background. If it doesn't fail 
        # immediatelyit will raise an IO::WaitWritable (Errno::EINPROGRESS) 
        # indicating the connection is in progress.
        @socket.connect_nonblock(sockaddr)
      rescue IO::WaitWritable
        # IO.select will block until the socket is writable or the timeout
        # is exceeded - whichever comes first.
        unless IO.select(nil, [@socket], nil, connect_timeout)
          # IO.select returns nil when the socket is not ready before timeout 
          # seconds have elapsed
          socket.close
          raise Errno::ETIMEDOUT
        end

        begin
          # Verify there is now a good connection.
          @socket.connect_nonblock(sockaddr)
        rescue Errno::EISCONN
          # The socket is connected, we're good!
        rescue
          # An unexpected exception was raised - the connection is no good.
          @socket.close
          raise
        end
      end
    end

    def read
      unless IO.select([@socket], nil, nil, @timeout)
        raise Errno::ETIMEDOUT
      end

      @socket.gets
    rescue IO::EAGAINWaitReadable
      retry
    end

    def write(bytes)
      unless IO.select(nil, [@socket], nil, @timeout)
        raise Errno::ETIMEDOUT
      end

      @socket.write(bytes)
    end

    def close
      @socket.close
    end

    def closed?
      @socket.closed?
    end

    def set_encoding(encoding)
      @socket.set_encoding(encoding)
    end
  end
end
