require 'ip_conversion'

class Rule < ActiveRecord::Base
  include IPConvert
  belongs_to :group
  
  # TODO: make rules convert to sql easily
  #  current idea -- have a to_sql method here
  #  to be used in the groups model to combine all the 
  #  rules sql.
  # def to_sql
  #   sql_statement = ""
  #   if(self.port_incoming_start)
  #     sql_statement << "streams.port_incoming is between #{self.port_incoming_start} and #{self.port_incoming_end}"
  #   end
  #   if(self.protocol)
  #   end
  # end
  
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
    sql_statement << queries.join(" AND ")
    sql_statement << ")"
    sql_statement
  end
  
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
