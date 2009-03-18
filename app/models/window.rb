class Window < ActiveRecord::Base
  belongs_to :stream
  named_scope :starting_between, lambda {|start,stop| {:conditions => ["start_time between ? and ?",start,stop]}}
  
  def between?(time)
    self.start_time <= time and self.end_time >= time
  end
end
