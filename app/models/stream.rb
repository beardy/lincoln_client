require 'ip_conversion'

class Stream < ActiveRecord::Base
  include IPConvert
  has_many :windows
  
  named_scope :starting_between, lambda {|start,stop| {:conditions => ["windows.start_time between ? and ?", start, stop],
                                                       :include => :windows} }
                                                       
  named_scope :filtered_by, lambda {|rule| {:conditions => rule.to_sql, :include => :windows } }
  
  def self.relevant_streams(time_range, *rules)
    scope = self.scoped({})
    scope = scope.starting_between(time_range.start_time, time_range.end_time)
    rules.each do |rule|
      scope = scope.filtered_by rule
    end
    scope
  end

  def groups(included_groups)
      included_groups.select { |group| group.contains?(self) }
  end

  def color(included_groups)
      group_list = (groups(included_groups))
    if (group_list.length == 0)
      '000000' # The color for no group association
    elsif (group_list.length == 1)
      group_list[0].color
    else
      'A68064' # The color for multiple group associations
    end
  end
  
  def port_incoming_name
    port_name(self.port_incoming)
  end
  
  def port_outgoing_name
    port_name(self.port_outgoing)
  end
  
  def port_name(number)
    @port_names_hash ||= Stream.get_port_names
    name = @port_names_hash[number] ||= number
    name    
  end
  
  def ip_incoming_name
    host_name(self.ip_incoming)
  end
  
  def ip_outgoing_name
    host_name(self.ip_outgoing)
  end
  
  def host_name(ip)
    @host_names_hash ||= Stream.get_host_names
    name = @host_names_hash[ip] ||= ip
    name
  end
  
  def self.get_host_names
    unless @host_names_hash
      @host_names ||= HastName.find(:all)
      @host_names_hash = {}
      @host_names.inject(@host_names_hash) {|hash, host| hash[host.ip_address] = host.name; hash}
    end
    @host_names_hash
  end
  
  def self.get_port_names    
    unless @port_names_hash
      @port_names ||= PortName.find(:all)
      @port_names_hash = {}
      @port_names.inject(@port_names_hash) {|hash, port| hash[port.number] = port.name; hash}
    end
    @port_names_hash
  end
  
  def ip_incoming
    ip(raw_ip_incoming)
  end
  
  def ip_outgoing
    ip(raw_ip_outgoing)
  end
  
  def start_time
    self.windows[0].start_time
  end
  
  def end_time
    self.windows[-1].end_time
  end

  def duration
    end_time - start_time
  end
  
  def num_packets_incoming
    self.windows.inject(0) {|sum, window| sum + window.num_packets_incoming }
  end
  
  def num_packets_outgoing
    self.windows.inject(0) {|sum, window| sum + window.num_packets_outgoing }
  end

  def total_number_packets
    num_packets_incoming + num_packets_outgoing
  end
  
  def size_packets_incoming
    self.windows.inject(0) {|sum, window| sum + window.size_packets_incoming }
  end
  
  def size_packets_outgoing
    self.windows.inject(0) {|sum, window| sum + window.size_packets_incoming }
  end

  def total_packet_size
    size_packets_incoming + size_packets_outgoing
  end

end
