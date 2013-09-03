require "kyototycoon/client/version"
require "kyototycoon/client/record"

module Kyototycoon
  class Client
    attr_reader :host, :port, :timeout_ms, :connection

    def initialize(host, port, timeout_ms = 0)
      @host = host
      @port = port
      @timeout_ms = timeout_ms
      @connection = Kyototycoon::Connection.new(@host, @port, @timeout_ms)
    end

    def open
      @connection.open
    end

    def close
      raise "connection doesn't open" unless @connection && @connection.is_open
      @connection.close
    end

    def set(key, value)
      self.set_bulk({key => value})
    end

    def get(key)
      self.get_bulk([key])[0]
    end

    def remove(key)
      self.remove_bulk([key])
    end

    def script(method, key, value)
      self.script_bulk(method, { key => value } ) 
    end

    def set_bulk(keyvalues)
      records = []
      keyvalues.each do |k, v|
        records.push(Record.new(0, k, v, 0)
      end
      @connection.set(records)
    end

    def get_bulk(keys)
      records = []
      keys.each do |k|
        records.push(Record.new(0, k, nil, 0)
      end
      @connection.get(records)
    end

    def remove_bulk(keys)
      records = []
      keys.each do |k|
        records.push(Record.new(0, k, nil, 0)
      end 
      @connection.remove(records)
    end

    def script_bulk(method, keyvalues)
      records = []
      keyvalues.each do |k, v|
        records.push(Record.new(0, k, v, 0)
      end
      @connection.script(records)
    end
  end
end
