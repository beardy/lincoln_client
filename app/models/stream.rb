require 'ip_conversion'

class Stream < ActiveRecord::Base
  include IPConvert
  has_many :windows, :order => 'start_time'
  
  named_scope :starting_between, lambda {|start,stop| {:conditions => ["windows.start_time between ? and ?", start, stop],
                                                       :include => :windows, :order => "windows.start_time"} }
                                                       
  named_scope :filtered_by, lambda {|rule| {:conditions => rule.to_sql, :include => :windows, :order => "windows.start_time" } }
  
  def self.relevant_streams(time_range, *rules)
    scope = self.scoped({})
    scope = scope.starting_between(time_range.start_time, time_range.end_time)
    rules.each do |rule|
      scope = scope.filtered_by rule
    end
    scope
  end
  
  def port_incoming_name
    port_names_hash ||= Stream.get_names
    name = port_names_hash[self.port_incoming] ||= self.port_incoming
    name
  end
  
  def port_outgoing_name
    port_names_hash ||= Stream.get_names
    name = port_names_hash[self.port_outgoing] ||= self.port_outgoing
    name    
  end
  
  def self.get_names    
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
