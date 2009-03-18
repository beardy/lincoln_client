class Window < ActiveRecord::Base
  belongs_to :stream
  named_scope :starting_between, lambda {|start,stop| {:conditions => ["start_time between ? and ?",start,stop]}}
  
  def between?(time)
    self.start_time <= time and self.end_time >= time
  end
  
  def data(direction, metric = :bytes)
    value = self.send(("size_packets_"+direction.to_s).to_sym)
    value.to_f / 1.send(metric).to_f
  end
end
