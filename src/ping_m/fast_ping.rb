require 'benchmark'
require_relative './ping_m'

def fast_ping ip
  time_icmp = Benchmark.measure {
    up? ip
  }
  time_icmp.real * 1000 
end