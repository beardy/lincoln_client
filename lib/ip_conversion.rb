require "ipaddr"

# Simple conversions to be used in converting
#  the raw version of an ip address to a human
#  readable format, and vice versa. 
#  Might be a better way to include them into
#  the models that use them (stream & rule)
module IPConvert
  
  def ip(raw_ip)
    IPAddr.new(raw_ip, Socket::AF_INET).to_s if raw_ip
  end

  def raw_ip(ip)
    IPAddr.new(ip).to_i if ip
  end
end