require 'ip_conversion'
class HostName < ActiveRecord::Base
  include IPConvert
  def ip_address
    ip(raw_ip_address) || @ip_is
  end
  
  def ip_address=(new_ip)
    self.raw_ip_address = raw_ip(new_ip)
    @ip_is = new_ip.empty? ? nil : new_ip
    self
  end
  
end
