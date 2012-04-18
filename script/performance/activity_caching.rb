#!/usr/bin/env ruby
require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__),'..','..','config','environment'))
require "benchmark"

def test_activity_caching
  Activity.all.each do |a|
    a.budget
  end
end

Benchmark.bmbm(7) do |x|
  x.report("first:")  { test_activity_caching }
  x.report("second:") { test_activity_caching }
  x.report("third:")  { test_activity_caching }
end

