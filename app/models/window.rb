class Window < ActiveRecord::Base
  belongs_to :stream
  named_scope :starting_between, lambda {|start,stop| {:conditions => ["start_time between ? and ?",start,stop]}}
  
  def between?(time)
    self.start_time <= time and self.end_time >= time
  end
  
  # direction can be :incoming, :outgoing, or :all
  # metric is by default just bytes, but it can be :kilobytes
  #  or some larger metric
  def data(direction, metric = :bytes)
    value = self.send(("size_packets_"+direction.to_s).to_sym)
    value.to_f / 1.send(metric.to_sym).to_f
  end
  
  # combines both incoming and outgoing packet sizes
  def size_packets_all
    self.size_packets_incoming + self.size_packets_outgoing
  end
  
  # combines both incoming and outgoing packet numbers
  def num_packets_all
    self.num_packets_incoming + self.num_packets_outgoing
  end
end
