require "kyototycoon/client/version"
require "kyototycoon/client/record"
require "kyototycoon/client/connection"

module Kyototycoon
  class Client
    attr_reader :host, :port, :timeout_ms, :connection

    def initialize(host, port, timeout_ms = 0)
      @host = host
      @port = port
      @timeout_ms = timeout_ms
      @connection = Connection.new(@host, @port, @timeout_ms)
    end

    def open
      @connection.open
    end

    def close
      raise "connection doesn't open" unless @connection && @connection.is_open
      @connection.close
    end

    def set(key, value)
      set_bulk({key => value}) == 1 ? true : false
    end

    def get(key)
      get_bulk([key])[key]
    end

    def remove(key)
      remove_bulk([key]) == 1 ? true : false
    end

    def script(method, key, value)
      script_bulk(method, { key => value } ) 
    end

    def set_bulk(keyvalues)
      raise "connection closed" unless @connection.is_open

      records = []
      keyvalues.each do |k, v|
        records.push(Record.new(k, v))
      end
      @connection.set(records)
    end

    def get_bulk(keys)
      raise "connection closed" unless @connection.is_open

      records = []
      keys.each do |k|
        records.push(Record.new(k, nil))
      end
      results = @connection.get(records)
      return {} if results == nil
      results.inject({}) {|map, rec| map[rec.key] = rec.value; map;}
    end

    def remove_bulk(keys)
      raise "connection closed" unless @connection.is_open

      records = []
      keys.each do |k|
        records.push(Record.new(k, nil))
      end 
      @connection.remove(records)
    end

    def script_bulk(method, keyvalues)
      raise "connection closed" unless @connection.is_open

      records = []
      keyvalues.each do |k, v|
        records.push(Record.new(k, v))
      end
      results = @connection.script(records)
      return {} if results == nil
      results.inject({}) {|map, rec| map[rec.key] = rec.value; map;}
    end
  end
end
