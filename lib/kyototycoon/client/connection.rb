require "socket"
require "magic"
require "flag"

module Kyototycoon
  class Connection
    attr_reader :host, :port, :timeout_ms, :socket, :is_open

    def initialize(host, port, timeout_ms)
      @host = host
      @port = port
      @timeout_ms = timeout_ms
      @is_open = false
    end

    def open
      return if @is_open
      @socket = TCPSocket.open(host, port)
      @is_open = true
    end

    def close
      return unless @is_open
      @socket.close
      @is_open = false
    end

    def set(records)
      header_entries = [Kyototycoon::Magic::SET_BULK, Kyototycoon::Flag::RESERVED, records.length]
      request = header_entries.pack("Cnn")

      records.each do |r|
        body_entries = [r.db_id, r.key.length, r.value.length, 0, r.expire.to_i]
        body = body_entries.pack("nNNNN") + r.key + r.value
        request = request + body
      end

      @socket.write(request)
      response = @socket.read(5) 
      magic, count = response.unpack("CN")
      raise "invalid protocol header" unless magic == Kyototycoon::Magic::SET_BULK

      count.to_i # number of registerd
    end

    def get(records)
      header_entries = [Kyototycoon::Magic::GET_BULK, Kyototycoon::Flag::RESERVED, records.length]
      request = header_entries.pack("Cnn")

      records.each do |r|
        body_entries = [r.db_id, r.key.length]
        body = body_entries.pack("nN") + r.key
        request = request + body
      end

      @socket.write(request)
      res_header = @socket.read(5)
      magic, count = response.unpack("CN")
      raise "invalid protocol header" unless magic == Kyototycoon::Magic::GET_BULK

      results = []
      count.times do |i|
        res_body = @socket.read(18)
        dbid, keysize, valuesize, ext_expire, expire = res_body.unpack("nNNNN")
        key = @socket.read(keysize)
        value = @socket.read(valuesize)
        results.push(Record.new(dbid, key, value, expire))
      end

      results
    end

    def remove
      header_entries = [Kyototycoon::Magic::REMOVE_BULK, Kyototycoon::Flag::RESERVED, records.length]
      request = header_entries.pack("Cnn")

      records.each do |r|
        body_entries = [r.db_id, r.key.length]
        body = body_entries.pack("nN") + r.key
        request = request + body
      end

    
      @socket.write(request)
      response = @socket.read(5) 
      magic, count = response.unpack("CN")
      raise "invalid protocol header" unless magic == Kyototycoon::Magic::REMOVE_BULK

      count.to_i # number of registerd
    end

    def script
      header_entries = [Kyototycoon::Magic::PLAY_SCRIPT, Kyototycoon::Flag::RESERVED, records.length]
      request = header_entries.pack("Cnn")

      records.each do |r|
        body_entries = [r.key.length, r.value.length]
        body = body_entries.pack("NN") + r.key + r.value
        request = request + body
      end

      @socket.write(request)
      res_header = @socket.read(5)
      magic, count = response.unpack("CN")
      raise "invalid protocol header" unless magic == Kyototycoon::Magic::PLAY_SCRIPT

      results = []
      count.times do |i|
        res_body = @socket.read(8)
        keysize, valuesize = res_body.unpack("NN")
        key = @socket.read(keysize)
        value = @socket.read(valuesize)
        results.push(Record.new(0, key, value, 0))
      end

      results
    end
  end
end
