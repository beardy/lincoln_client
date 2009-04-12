require 'ip_conversion'
class HostName < ActiveRecord::Base
  
  validates_presence_of :raw_ip_address, :name
  validates_uniqueness_of :raw_ip_address, :name
  
  validates_format_of :ip_address,
                      :with => /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
  
  
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
