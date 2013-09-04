require "helper"

class ClientTest < Test::Unit::TestCase
  def setup
    @client = (ENV["HOST"] && ENV["PORT"]) ? Kyototycoon::Client.new(ENV["HOST"], ENV["PORT"].to_i) : nil
  end

  def test_open
    return unless @client

    @client.open
    @client.close
  end


  def test_clud
    return unless @client

    @client.open
    assert_equal(@client.set("key1", "value1"), true)
    assert_equal(@client.get("key1"), "value1")
    assert_nil(@client.get("key999"))
    assert_equal(@client.remove("key1"), true)
    assert_nil(@client.get("key1"))
    @client.close
  end

  def test_clud_bulk
    return unless @client

    @client.open
    assert_equal( @client.set_bulk( {"key1" => "valueA", "key2" => "valueB", "key3" => "valueC"} ), 3)
    assert_equal( @client.get_bulk( ["key1", "key2", "key3", "key4"] ), 
                                    {"key1" => "valueA", "key2" => "valueB", "key3" => "valueC"} )
    assert_equal( @client.remove_bulk( ["key1", "key2"] ), 2 )
    assert_equal( @client.get_bulk( ["key1", "key2", "key3", "key4"] ), 
                                    {"key3" => "valueC"} )
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
