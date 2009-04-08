require 'ip_conversion'

class Rule < ActiveRecord::Base
  include IPConvert
  belongs_to :group
  
  validates_numericality_of :port_incoming_start, :port_incoming_end, :port_outgoing_start, :port_outgoing_end, :allow_nil => true
  #Nasty IP regular expression is from http://www.regular-expressions.info/examples.html
  validates_format_of :ip_incoming_start, :ip_incoming_end, :ip_outgoing_start, :ip_outgoing_end, 
                      :with => /^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/,
                      :allow_nil => true
  
  def after_initialize
    self.port_outgoing_end ||= self.port_outgoing_start
    self.port_incoming_end ||= self.port_incoming_start
    self.raw_ip_incoming_end ||= self.raw_ip_incoming_start
    self.raw_ip_outgoing_end ||= self.raw_ip_outgoing_start
  end
  
  def to_sql
    sql_statement = ""
    queries = []
    if(self.not_flag)
      sql_statement << "NOT("
    else
      sql_statement << "("
    end
    if(self.port_incoming_start && self.port_incoming_end)
      queries << "streams.port_incoming between #{self.port_incoming_start} and #{self.port_incoming_end}"
    end
    if(self.port_outgoing_start && self.port_outgoing_end)
      queries << "streams.port_outgoing between #{self.port_outgoing_start} and #{self.port_outgoing_end}"
    end
    if(self.raw_ip_incoming_start && self.raw_ip_incoming_end)
      queries << "streams.raw_ip_incoming between #{self.raw_ip_incoming_start} and #{self.raw_ip_incoming_end}"
    end
    if(self.raw_ip_outgoing_start && self.raw_ip_outgoing_end)
      queries << "streams.raw_ip_outgoing between #{self.raw_ip_outgoing_start} and #{self.raw_ip_outgoing_end}"
    end
    sql_statement << queries.join(" AND ")
    sql_statement << ")"
    sql_statement = sql_statement.gsub(/(\(\))/,"").strip.empty? ? "" : sql_statement
    sql_statement
  end
  
  # methods convert the raw
  # ip addresses to human
  # friendly versions
  def ip_incoming_start
    ip(raw_ip_incoming_start) || @ip_is
  end
  
  def ip_incoming_start=(new_ip)
    self.raw_ip_incoming_start = raw_ip(new_ip)
    @ip_is = new_ip.empty? ? nil : new_ip
    self
  end
  
  def ip_incoming_end
    ip(raw_ip_incoming_end) || @ip_ie
  end
  
  def ip_incoming_end=(new_ip)
    self.raw_ip_incoming_end = raw_ip(new_ip)
    @ip_ie = new_ip.empty? ? nil : new_ip
    self
  end
  
  def ip_outgoing_start
    ip(raw_ip_outgoing_start) || @ip_os
  end
  
  def ip_outgoing_start=(new_ip)
    self.raw_ip_outgoing_start = raw_ip(new_ip)
    @ip_os = new_ip.empty? ? nil : new_ip
    self
  end
  
  def ip_outgoing_end
    ip(raw_ip_outgoing_end) || @ip_oe
  end
  
  def ip_outgoing_end=(new_ip)
    self.raw_ip_outgoing_end = raw_ip(new_ip)
    @ip_oe = new_ip.empty? ? nil : new_ip
    self
  end  
end
