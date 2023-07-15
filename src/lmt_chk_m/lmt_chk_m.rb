def lmt_chk first_ip, speed, idx
  if first_ip[idx] > speed
    loop do
      ((idx.abs).times {|x| first_ip[-(x+1)].next! })
      if first_ip[idx] == '254'
        break
      end
    end
  end
end