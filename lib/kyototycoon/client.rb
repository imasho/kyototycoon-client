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

    def set(key, value, expire=Record::MAX_EXPIRE_SECONDS, dbid=0)
      set_bulk({key => [value, expire]}, dbid) == 1 ? true : false
    end

    def get(key, dbid=0)
      get_bulk([key], dbid)[key]
    end

    def remove(key)
      remove_bulk([key]) == 1 ? true : false
    end

    def script(method, key, value)
      script_bulk(method, { key => value } )
    end

    def set_bulk(keyvalues, dbid = 0)
      return 0 if keyvalues.empty?
      raise "connection closed" unless @connection.is_open

      records = []
      keyvalues.each do |k, v|
        if v.is_a?(Array)
          records.push(Record.new(k, v[0], v[1].to_i, dbid))
        else
          records.push(Record.new(k, v, Record::MAX_EXPIRE_SECONDS, dbid))
        end
      end
      @connection.set(records)
    end

    def get_bulk(keys, dbid=0)
      return {} if keys.empty?
      raise "connection closed" unless @connection.is_open

      records = []
      keys.each do |k|
        records.push(Record.new(k, nil, nil, dbid))
      end
      results = @connection.get(records)
      return {} if results == nil
      results.inject({}) {|map, rec| map[rec.key] = rec.value; map;}
    end

    def remove_bulk(keys, dbid=0)
      return 0 if keys.empty?
      raise "connection closed" unless @connection.is_open

      records = []
      keys.each do |k|
        records.push(Record.new(k, nil, nil, dbid))
      end
      @connection.remove(records)
    end

    def script_bulk(method, keyvalues)
      raise "connection closed" unless @connection.is_open

      records = []
      keyvalues.each do |k, v|
        records.push(Record.new(k, v))
      end
      results = @connection.script(method, records)
      return {} if results == nil
      results.inject({}) {|map, rec| map[rec.key] = rec.value; map;}
    end
  end
end
