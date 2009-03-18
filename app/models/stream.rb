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
													   
  def ip_incoming
    ip(raw_ip_incoming)
  end
  
  def ip_outgoing
    ip(raw_ip_outgoing)
  end

  def start_time
    windows.minimum :start_time
  end

  def end_time
    windows.maximum :end_time
  end

  def num_packets_incoming
    windows.sum :num_packets_incoming
  end

  def num_packets_outgoing
    windows.sum :num_packets_outgoing
  end

  def size_packets_incoming
    windows.sum :size_packets_incoming
  end

  def size_packets_outgoing
    windows.sum :size_packets_outgoing
  end

end
