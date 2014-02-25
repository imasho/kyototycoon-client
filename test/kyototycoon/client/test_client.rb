# coding: utf-8
require "helper"

class ClientTest < Test::Unit::TestCase

  HOST = ENV["HOST"] || "localhost"
  PORT = (ENV["PORT"] || 1978).to_i

  def setup
    raise "host and port of KyotoTycoon test server is required: rake test HOST=xxx PORT=xxx" if (!HOST || !PORT)
    @client = Kyototycoon::Client.new(HOST, PORT)
  end

  def test_open
    @client.open
    @client.close
  end


  def test_clud
    @client.open
    assert_equal(@client.set("key1", "value1"), true)
    assert_equal(@client.get("key1"), "value1")
    assert_nil(@client.get("key999"))
    assert_equal(@client.remove("key1"), true)
    assert_nil(@client.get("key1"))
    @client.close
  end

  def test_clud_multibyte_characters
    @client.open
    assert_equal(@client.set("あ", "あいのまち"), true)
    assert_equal(@client.get("あ"), "あいのまち")
    assert_nil(@client.get("ん"))
    assert_equal(@client.remove("あ"), true)
    assert_nil(@client.get("あ"))
    @client.close
  end

  def test_clud_bulk
    @client.open
    @client.remove_bulk(["key1", "key2", "key3", "key4"])

    assert_equal( @client.set_bulk( {"key1" => "valueA", "key2" => "valueB", "key3" => "valueC"} ), 3)
    assert_equal( @client.get_bulk( ["key1", "key2", "key3", "key4"] ),
                  {"key1" => "valueA", "key2" => "valueB", "key3" => "valueC"} )
    assert_equal( @client.remove_bulk( ["key1", "key2"] ), 2 )
    assert_equal( @client.get_bulk( ["key1", "key2", "key3", "key4"] ),
                  {"key3" => "valueC"} )
    @client.close
  end

  def test_clud_bulk_multibyte_charactors
    @client.open
    @client.remove_bulk(["あ", "い", "う", "え"])

    assert_equal( @client.set_bulk( {"あ" => "あいのまち", "い" => "いしかずちょう", "う" => "ういろうのちょう"} ), 3)
    assert_equal( @client.get_bulk( ["あ", "い", "う", "え"] ),
                  {"あ" => "あいのまち", "い" => "いしかずちょう", "う" => "ういろうのちょう"} )
    assert_equal( @client.remove_bulk( ["あ", "い"] ), 2 )
    assert_equal( @client.get_bulk( ["あ", "い", "う", "え"] ),
                  {"う" => "ういろうのちょう"} )
    @client.close
  end

  def test_expire
    @client.open
    assert_equal(@client.set_bulk( {"key1" => ["value1", 1]} ), 1)   # expire after 1 second
    assert_equal(@client.set_bulk( {"key2" => "value2"} ), 1)        # not expire
    assert_equal(@client.set("key3", "value3"), true)                # not expire
    assert_equal(@client.set("key4", "value4", 1), true)             # expire after 1 second

    assert_equal(@client.get("key1"), "value1")
    assert_equal(@client.get("key2"), "value2")
    assert_equal(@client.get("key3"), "value3")
    assert_equal(@client.get("key4"), "value4")
    sleep 3
    assert_equal(@client.get("key1"), nil)
    assert_equal(@client.get("key2"), "value2")
    assert_equal(@client.get("key3"), "value3")
    assert_equal(@client.get("key4"), nil)
    @client.remove_bulk( ["key2", "key3"] )
    @client.close
  end

  def test_expire_multibyte_characters
    @client.open
    assert_equal(@client.set_bulk( {"あ" => ["あいのまち", 1]} ), 1)   # expire after 1 second
    assert_equal(@client.set_bulk( {"い" => "いしかずちょう"} ), 1)        # not expire
    assert_equal(@client.set("う", "ういろうのちょう"), true)                # not expire
    assert_equal(@client.set("え", "えびすがわ", 1), true)             # expire after 1 second

    assert_equal(@client.get("あ"), "あいのまち")
    assert_equal(@client.get("い"), "いしかずちょう")
    assert_equal(@client.get("う"), "ういろうのちょう")
    assert_equal(@client.get("え"), "えびすがわ")
    sleep 3
    assert_equal(@client.get("あ"), nil)
    assert_equal(@client.get("い"), "いしかずちょう")
    assert_equal(@client.get("う"), "ういろうのちょう")
    assert_equal(@client.get("え"), nil)
    @client.remove_bulk( ["い", "う"] )
    @client.close
  end

  def test_dbid
    @client.open
    assert_equal(@client.set_bulk( {"あ" => "あいのまち"}, 0 ), 1)
    assert_equal(@client.set_bulk( {"あ" => "あいのまち"}, 1 ), 0)
    assert_equal(@client.get("あ", 0), "あいのまち")
    assert_equal(@client.get("あ", 1), nil)
    @client.close
  end

  def test_empty_records
    client = Kyototycoon::Client.new(HOST, PORT)
    client.instance_eval do |obj|
      class << self
        define_method :connection=, Proc.new { |connection|
          @connection = connection
        }
      end
    end

    mock = MockConnection.new
    client.connection = mock

    client.get_bulk([])
    assert_equal false, mock.called_get?

    client.set_bulk([])
    assert_equal false, mock.called_set?

    client.remove_bulk([])
    assert_equal false, mock.called_remove?

    client.get(1)
    assert_equal true, mock.called_get?

    client.set(1, 1)
    assert_equal true, mock.called_set?

    client.remove(1)
    assert_equal true, mock.called_remove?
  end


  # def test_script
  #   return unless @client

  #  @client.open
  #  assert_equal( @client.script("dummy", "key", "value"), {} )
  #  assert_equal( @client.script_bulk("dummy", {}), {} )
  #  @client.close
  # end
end

class MockConnection
  def initialize
    @get    = false
    @set    = false
    @remove = false
  end

  def is_open
    true
  end

  def get(records)
    @get = true
    []
  end

  def set(records)
    @set = true
    0
  end

  def remove(records)
    @remove = true
    true
  end

  def called_get?
    @get
  end

  def called_set?
    @set
  end

  def called_remove?
    @remove
  end
end
