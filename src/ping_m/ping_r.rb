require 'net/ping'

def up? host
  p1 = Net::Ping::External.new(host)
  p1.ping?
end

def up_tcp? host
  p1 = Net::Ping::TCP.new(host, 'http')
  p1.ping?
end

def up_udp? host
  p1 = Net::Ping::UDP.new(host)
  p1.ping?
end
