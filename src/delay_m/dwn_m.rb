require 'benchmark'
require 'faraday'

def tst_dl(ip, dl_size=1024, min_speed_bytes=12500)
  headers = {'Content-Type': 'multipart/form-data', 'Host': 'speed.cloudflare.com'}
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
