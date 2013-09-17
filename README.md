# Kyototycoon::Client

KyotoTycoon ruby client with TCP connection and binary protocol.

## Changelog

* 0.0.2: Add dbid parameter to remove_bulk


## Installation

Add this line to your application's Gemfile:

    gem 'kyototycoon-client'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kyototycoon-client

## Usage

### Create instance

    require "kyototycoon/client"
    
    client = Kyototycoon::Client.new(host, port)
    client.open
    
    # kyototycoon operations here
    
    client.close

### get/ret/remove operations

Simple case:  

    > client.set("key", "value")  # set single key-value
    => true
    > client.set_bulk({"key1" => "value1", "key2" => "value2"})  # set multiple key-value
    => 2  # number of success key-value set
    > client.get("key")  # get single key 
    => "value" # return value or nil
    > client.get_bulk(["key1", "key2"]) # set multiple keys
    => {"key1" => "value1", "key2" => "value2"}  # return key-value map

Key expiration:  

    > client.set("key", "value", 3600) # third parameter is seconds for key expiration
    => true
    > client.set_bulk({"key1" => ["value1", 3600], "key2" => "value2"})  # key1 will expire after 3600 seconds, key2 never expire
    => 2

Remove key:  

    > client.remove("key")  # remove signle key
    => true
    > client.remove_bulk(["key1", "key2"]) # remove multiple keys 
    => 2   # number of keys removed

### Play LUA script

KyotoTyccon supports server-side LUA scripting extention.

Client can call LUA method with method name and key-value set arguments.

Client receives response as key-value set format.

    > client.script("key", "value")  # single key-value argument
    => {"keyA" => "valueA", "keyB" => "valueB", ...}  # receive key-value set
    > client.script({"key1" => "value1", "key2" => "value2"})  # multiple key-value argument
    => {"keyX" => "valueX", "keyY" => "valueY", ... } 

Number of key sent and number of key received are depend on LUA function definition.
