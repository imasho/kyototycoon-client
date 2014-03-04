#!/usr/bin/ruby

require "rubygems"
require "kyototycoon/client"
require "benchmark"

if ARGV.length != 2 && ARGV.length != 3
  print "usage: ruby benchmark.rb [HOST] [PORT]\n"
  exit 1
end

client = Kyototycoon::Client.new(ARGV[0], ARGV[1])
client.open
bench_count = (ARGV[2] || 100000).to_i

records = {}
bench_count.times do |i|
  records["testdata#{i}"] = "value#{i}"
end

Benchmark.bm do |b|
  b.report("set_bulk: ") {
    client.set_bulk(records)
  }

  b.report("set     : ") {
    bench_count.times do |i|
      client.set("iteration#{i}", "value#{i}")
    end
  }

  b.report("get_bulk: ") {
    result = client.get_bulk(records.keys)
    raise unless result.size == bench_count
  }
  
  b.report("get     : ") {
    bench_count.times do |i|
      v = client.get("iteration#{i}")
      raise unless v == "value#{i}"
    end
  }

end

client.close
exit 0
