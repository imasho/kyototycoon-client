require "socket"
require "kyototycoon/client/magic"
require "kyototycoon/client/flag"


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
      header_entries = [Magic::SET_BULK, Flag::RESERVED, records.length]
      request = header_entries.pack("CNN")

      records.each do |r|
        body_entries = [r.db_id, r.key.length, r.value.length, r.expire.to_i >> 32, r.expire.to_i & 0x00000000FFFFFFFF]
        request << body_entries.pack("nNNNN") << r.key << r.value
      end

      @socket.write(request)
      response = @socket.read(5) 
      raise "no response" unless response

      magic, count = response.unpack("CN")
      raise "invalid protocol header" unless magic == Magic::SET_BULK

      count.to_i # number of registerd
    end

    def get(records)
      header_entries = [Magic::GET_BULK, Flag::RESERVED, records.length]
      request = header_entries.pack("CNN")

      records.each do |r|
        body_entries = [r.db_id, r.key.length]
        request << body_entries.pack("nN") << r.key
      end

      @socket.write(request)
      res_header = @socket.read(5)
      raise "no response" unless res_header

      magic, count = res_header.unpack("CN")
      raise "invalid protocol header" unless magic == Magic::GET_BULK

      results = []
      count.times do |i|
        res_body = @socket.read(18)

        dbid, keysize, valuesize, ext_expire, expire = res_body.unpack("nNNNN")
        expire = ext_expire << 32 | expire

        key = @socket.read(keysize)
        value = @socket.read(valuesize)
        results.push(Record.new(key, value, dbid, expire))
      end

      results
    end

    def remove(records)
      header_entries = [Magic::REMOVE_BULK, Flag::RESERVED, records.length]
      request = header_entries.pack("CNN")

      records.each do |r|
        body_entries = [r.db_id, r.key.length]
        request << body_entries.pack("nN") << r.key
      end
    
      @socket.write(request)
      response = @socket.read(5) 
      raise "no response" unless response

      magic, count = response.unpack("CN")
      raise "invalid protocol header" unless magic == Magic::REMOVE_BULK

      count.to_i # number of registerd
    end

    def script(records)
      header_entries = [Magic::PLAY_SCRIPT, Flag::RESERVED, records.length]
      request = header_entries.pack("CNN")

      records.each do |r|
        body_entries = [r.key.length, r.value.length]
        request << body_entries.pack("NN") << r.key << r.value
      end

      @socket.write(request)
      res_header = @socket.read(5)
      raise "no response" unless res_header

      magic, count = res_header.unpack("CN")
      raise "invalid protocol header" unless magic == Magic::PLAY_SCRIPT

      results = []
      count.times do |i|
        res_body = @socket.read(8)
        keysize, valuesize = res_body.unpack("NN")
        key = @socket.read(keysize)
        value = @socket.read(valuesize)
        results.push(Record.new(key, value, 0, 0))
      end

      results
    end
  end
end


