require 'bundler/gem_helper'
require 'rake/testtask'

Bundler::GemHelper.new(Dir.pwd).instance_eval do
  desc "Build #{name}-#{version}.gem into the pkg directory"
  task 'build' do
    build_gem
  end

  desc "Build and install #{name}-#{version}.gem into system gems"
  task 'install' do
    install_gem
  end

  desc "benchmark module"
  task 'benchmark' do
    raise "host and port reauired: rake benchmark HOST=[HOST] PORT=[PORT]" if !ENV["HOST"] || !ENV["PORT"]

    if ENV["COUNT"].to_i > 0
      system "ruby test/benchmark.rb #{ENV["HOST"]} #{ENV["PORT"]} #{ENV["COUNT"]}"
    else
      system "ruby test/benchmark.rb #{ENV["HOST"]} #{ENV["PORT"]}"
    end
  end
end


Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
end

task :default => :test
