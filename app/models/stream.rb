require 'ip_conversion'

class Stream < ActiveRecord::Base
  include IPConvert
  has_many :windows, :order => 'start_time'
  
  # Named scopes are bad-ass. Here we're scoping the returned 
  # streams based on start and stop times for its windows
  # which are brought in when we call it (which is why we need the lambda)
  # See the groups controller index method for an example of use
  named_scope :starting_between, lambda {|start,stop| {:conditions => ["windows.start_time between ? and ?", start, stop],
                                                       :include => :windows, :order => "windows.start_time"} }
                                                       
  named_scope :filtered_by, lambda {|rule| {:conditions => rule.to_sql } }

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
