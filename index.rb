#!/usr/bin/ruby
require 'benchmark'
require 'whois'
require 'faraday'
require 'faraday/multipart'
require 'net/ping'

puts `cat ./banner.txt`

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

def find_cloudflare_ips ip
  begin
    whois = Whois::Client.new
    whois.lookup ip
  rescue Timeout::Error => ex
    'pass'
  end
end

def analyze_whois(ip, text)
  if text.scan /cloudflare/
    d = ip.split('.')
    d[-1] = '0'
    system('clear')
    puts "[+] #{d.join('.')} is part of cloudflare network"
    if rand(10...15) == 12
      `echo #{d.join('.')} >> cf_subnets.txt`
    end
  end
end

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

def fast_ping ip
  time_icmp = Benchmark.measure {
    up? ip
  }
  time_icmp.real * 1000 
end

def tst_upl ip
  payload = { string: 'value' }
  nulb = "\x00"
  url = 'https://speed.cloudflare.com/__up'
  conn = Faraday.new(url) do |f|
    f.request :multipart
    f.request :url_encoded
  end

  payload[:raw_data] = Faraday::Multipart::ParamPart.new(
    { a: "\x00" * (1024 / 4) },
    'multipart/form-data',
    'Host' => 'speed.cloudflare.com'
  )

  response = ''
  time = Benchmark.measure {
    response = conn.post('', payload)
  }

  if response.status == 200
    puts "[+] upload delay is: #{(time.real * 1000)}" 
  end

end

def tst_dl ip
  headers = {'Content-Type': 'multipart/form-data', 'Host': 'speed.cloudflare.com'}
  dl_size = 1024
  min_speed_bytes = 12500
  timeout = dl_size / min_speed_bytes
  url = "https://speed.cloudflare.com/__down?bytes=#{dl_size}"
  
  headers = {'Host' => 'speed.cloudflare.com'}
  params = {'resolve' => "speed.cloudflare.com:443:#{ip}"}

  response = ""
  time = Benchmark.measure {
    response = Faraday.get url, params, headers
  }

  if response.status == 200
    puts "[+] download delay is: #{ (time.real * 1000) }" 
  end
end

def brute_ips mode
  first_ip = ['001', '001', '001', '001'] # dns
  res_count = [0, 0, 0, 0]
  
  loop do
    if first_ip[-1] == '254'
      first_ip[-1] = '001'
      first_ip[-2].next!
    end
    if first_ip[-2] == '254'
      (-2..-1).to_a.reverse.each {|x| first_ip[x] = '001'}
      first_ip[-3].next!
    end
    if first_ip[-3] == '254'
      (-3..-1).to_a.reverse.each {|x| first_ip[x] = '001'}
      first_ip[-4].next!
    end
    first_ip[-1].next!
    ry = ""
    first_ip.select {|x| ry = ry+".#{x.to_i}"}
    i = ry[1..-1]
    puts "[!] looking up: #{i}"
    if analyze_whois(i ,find_cloudflare_ips(i).to_s)
      # send requests to cloudflare to test speed
      f_ping = fast_ping i
      if f_ping < 400
        p "[+] ping is under 400"
        tst_dl i
        tst_upl i
        tst_lat_ping i
      end

      loop do
        first_ip[-1].next! 
        if first_ip[-1] == '254'
          break
        end
      end

      speed = "002" 
      if mode == "fast"
        speed = "002"
      elsif mode == "medium"
        speed = "020"
      elsif mode == "slow"
        speed = "120"
      end

      if first_ip[-2] > speed 
        loop do
          first_ip[-1].next! 
          first_ip[-2].next! 
          if first_ip[-2] == '254'
            break
          end
        end
      end

      if first_ip[-3] > speed
        loop do
          first_ip[-1].next! 
          first_ip[-2].next! 
          first_ip[-3].next! 
          if first_ip[-3] == '254'
            break
          end
        end
      end
        
    end

  end
end


def main
  brute_ips "fast" 
end

main