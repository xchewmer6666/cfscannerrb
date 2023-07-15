require 'whois'

def find_cloudflare_ips ip
  begin
    whois = Whois::Client.new
    whois.lookup ip
  rescue Timeout::Error => ex
    'pass'
  end
end