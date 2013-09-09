#!/usr/bin/ruby

require "rubygems"
require "kyototycoon/client"
require "benchmark"

if ARGV.length != 2
  print "usage: ruby benchmark.rb [HOST] [PORT]\n"
  print "       rake benchmark HOST=[HOST] PORT=[PORT]\n"
  exit 1
end

BENCH_COUNT=100000

client = Kyototycoon::Client.new(ARGV[0], ARGV[1])
client.open

records = {}
BENCH_COUNT.times do |i|
  records["testdata#{i}"] = "value#{i}"
end

Benchmark.bm do |b|
  b.report("set_bulk: ") {
    client.set_bulk(records)
  }

  b.report("set     : ") {
    BENCH_COUNT.times do |i|
      client.set("iteration#{i}", "value#{i}")
    end
  }

  b.report("get_bulk: ") {
    result = client.get_bulk(records.keys)
    raise unless result.size == BENCH_COUNT
  }
  
  b.report("get     : ") {
    BENCH_COUNT.times do |i|
      v = client.get("iteration#{i}")
      raise unless v == "value#{i}"
    end
  }

end

client.close
exit 0
