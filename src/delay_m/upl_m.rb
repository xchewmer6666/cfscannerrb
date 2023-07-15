require 'faraday'
require 'faraday/multipart'

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
