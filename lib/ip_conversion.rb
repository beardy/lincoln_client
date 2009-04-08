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
    # raw = nil
    # begin
    #   raw = IPAddr.new(ip).to_i unless ip.empty? or !valid_ip(ip)
    # rescue
    #   raw = nil
    # end
    # raw
    IPAddr.new(ip).to_i unless ip.empty? or !valid_ip(ip)
  end
  
  #Nasty IP regular expression is from http://www.regular-expressions.info/examples.html
  def valid_ip(ip)
    ip =~ /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  end
end