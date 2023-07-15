#!/usr/bin/ruby
require 'optparse'
require 'benchmark'
require 'whois'
require_relative './src/ping_m/ping_m'
require_relative './src/whs_m/fnd_clf_m'
require_relative './src/whs_m/anlz_wh_m'
require_relative './src/delay_m/delay_index'
require_relative './src/lmt_chk_m/lmt_chk_m'

puts `cat ./banner.txt`

def mod_chk options
  if options[:mode] == "fast"
    options[:speed] = "001"
  elsif options[:mode] == "medium"
    options[:speed] = "020"
  elsif options[:mode] == "slow"
    options[:speed] = "120"
  end
end

def brute_ips options
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
      if f_ping < ping_icmp_lim
        p "[+] ping is under #{ping_icmp_lim}"
        tst_dl i
        tst_upl i
        tst_lat_ping i
      end

      mod_chk options[:mode], options[:speed]
      (((-3.abs)).times {|x| lmt_chk first_ip, options[:speed], -x})
        
    end
  end
end

def main
  options = {}
  OptionParser.new do |opt|
    opt.on('--mode MODE') { |o| options[:mode] = o }
    opt.on('--speed SPEED') { |o| options[:speed] = o }
    opt.on('--pingicmplim PINGICMPLIM') { |o| options[:pingicmplim] = o }
  end.parse!
  brute_ips options
end

main