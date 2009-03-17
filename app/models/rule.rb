require 'ip_conversion'

class Rule < ActiveRecord::Base
  include IPConvert
  belongs_to :group
  
  # TODO: make rules convert to sql easily
  #  current idea -- have a to_sql method here
  #  to be used in the groups model to combine all the 
  #  rules sql.
  # def to_sql
  # ... convert to a series of anded sql statements
  # end
  
  
  # creates a new Range
  #  representing the 
  #  range of the incoming ports
  def port_incoming_range
    create_range(port_incoming_start,
                 port_incoming_stop)
  end
  
  # creates a new Range for
  #  the outgoing port range
  def port_outgoing_range
    create_range(port_outgoing_start,
                 port_outgoing_stop)
  end
  
  # methods convert the raw
  # ip addresses to human
  # friendly versions
  def ip_incoming_start
    ip(raw_ip_incoming_start)
  end
  
  def ip_incoming_stop
    ip(raw_ip_incoming_end)
  end
  
  def ip_outgoing_start
    ip(raw_ip_outgoing_start)
  end
  
  def ip_outgoing_end
    ip(raw_ip_outgoing_end)
  end
  
  private
  
  def create_range(start,stop)
    Range.new(start,stop)
  end
  
end
