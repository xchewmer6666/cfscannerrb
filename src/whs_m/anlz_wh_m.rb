
def analyze_whois(ip, text)
  if text.scan /cloudflare/
    d = ip.split('.')
    d[-1] = '0'
    system('clear')
    puts "[+] #{d.join('.')} is part of cloudflare network"
    if rand(10...15) == 12
      `echo #{d.join('.')} >> ~/tools/cfscannerrb/outs/cf_subnets.txt`
    end
  end
end
