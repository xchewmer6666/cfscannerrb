require 'benchmark'
require_relative './ping_r'
require_relative './fast_ping'

def tst_lat_ping ip
  puts "[!] testing ICMP ping"
  up_a = [false, false, false]
  time_icmp = Benchmark.measure {
    up_a[0] = up? ip
  }
  time_tcp = Benchmark.measure {
    up_a[1] = up_tcp? ip
  }
  time_udp = Benchmark.measure {
    up_a[2] = up_udp? ip
  }

  p [up_a, {:t_icmp => time_icmp.real, :t_tcp => time_tcp.real, :t_udp => time_udp.real}]
end