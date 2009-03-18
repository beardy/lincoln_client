class TimeRange
  attr_accessor :start_time, :end_time, :ticks, :window
  
  def initialize(start_time = 2.days.ago, end_time = Time.zone.now, args = {})
    args[:ticks] ||= 15
    args[:window] ||= 5.minutes
    @start_time = start_time
    @end_time = end_time
    @ticks = args[:ticks]
    @window = args[:window]
  end
  
  def update(time_point, new_time)
    # call the start_time = / end_time = method passin in new time
    self.send((time_point+"=").to_sym, new_time)
  end
  
  def duration
    end_time - start_time
  end
  
  def increment
    duration / ticks
  end
  
  def ratio
    increment / window
  end
  
  def each_tick_with_time
    ticks.times do |i|
      tick_time = start_time + (i * increment)
      yield i, tick_time
    end
  end
end