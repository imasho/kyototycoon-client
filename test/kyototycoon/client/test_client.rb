require "helper"

class ClientTest < Test::Unit::TestCase
  def setup
    raise "host and port of KyotoTycoon test server is required: rake test HOST=xxx PORT=xxx" if (!ENV["HOST"] || !ENV["PORT"])
    @client = Kyototycoon::Client.new(ENV["HOST"], ENV["PORT"].to_i) 
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

  def test_clud_bulk
    @client.open
    assert_equal( @client.set_bulk( {"key1" => "valueA", "key2" => "valueB", "key3" => "valueC"} ), 3)
    assert_equal( @client.get_bulk( ["key1", "key2", "key3", "key4"] ), 
                                    {"key1" => "valueA", "key2" => "valueB", "key3" => "valueC"} )
    assert_equal( @client.remove_bulk( ["key1", "key2"] ), 2 )
    assert_equal( @client.get_bulk( ["key1", "key2", "key3", "key4"] ), 
                                    {"key3" => "valueC"} )
    @client.close
  end

  def test_expire
    @client.open
    assert_equal(@client.set_bulk( {"key1" => ["value1", 1]} ), 1)   # expire after 1 second
    assert_equal(@client.set_bulk( {"key2" => "value2"} ), 1)        # not expire
    assert_equal(@client.get("key1"), "value1")
    assert_equal(@client.get("key2"), "value2")
    sleep 3
    assert_equal(@client.get("key1"), nil)
    assert_equal(@client.get("key2"), "value2")
    @client.close
  end

  def test_dbid
    @client.open
    assert_equal(@client.set_bulk( {"key1" => "value1"}, 0 ), 1)
    assert_equal(@client.set_bulk( {"key1" => "value1"}, 1 ), 0)
    assert_equal(@client.get("key1", 0), "value1")
    assert_equal(@client.get("key1", 1), nil)
    @client.close
  end

  # def test_script
  #   return unless @client

  #  @client.open
  #  assert_equal( @client.script("dummy", "key", "value"), {} )
  #  assert_equal( @client.script_bulk("dummy", {}), {} )
  #  @client.close
  # end
end
