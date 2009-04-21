class TimeRange
  attr_accessor :start_time, :end_time, :ticks, :window
  
  def initialize(start_time = 2.days.ago, end_time = Time.zone.now, args = {})
    args[:ticks] ||= 10
    @start_time = start_time
    @end_time = end_time
    @ticks = args[:ticks]
  end
  
  def update(time_point, new_time)
    # call the start_time = / end_time = method passin in new time
    self.send((time_point+"=").to_sym, Time.zone.parse(new_time))
  end
  
  def duration
    @end_time - @start_time
  end
  
  def increment
    duration / @ticks
  end
  
  def increment_index(time)
    ((time - @start_time) / increment).floor
  end
  
  def each_increment_with_ratio(window_start_time, window_end_time)
    start_increment_index = increment_index(window_start_time)
    end_increment_index = increment_index(window_end_time)
    # if window exists within one increment, sum all data
    if start_increment_index == end_increment_index
      yield start_increment_index, 1
    # else if window exists within multiple increments, sum data individually
    else
      window_duration = (window_end_time - window_start_time)
      # for each increment
	  num_increments = (end_increment_index - start_increment_index + 1)
	  num_increments = (start_increment_index + num_increments > @ticks) ? (@ticks - start_increment_index) : num_increments
      num_increments.times do |i|
        window_increment_start_time = [window_start_time, @start_time + (start_increment_index + i) * increment].max
        window_increment_end_time = [window_end_time, @start_time + (start_increment_index + i + 1) * increment].min
        window_increment_ratio = (window_increment_end_time - window_increment_start_time) / window_duration
        yield start_increment_index + i, window_increment_ratio
      end
    end
  end
  
  def each_tick_with_time
    ticks.times do |i|
      tick_time = start_time + (i * increment)
      yield i, tick_time
    end
  end
  
  def each_tick_with_strftime
	# initialize last day
	last_day = Time.at(0)
	
	# format each time
	each_tick_with_time do |i, time|
	  # calculate current day
	  this_day = Time.parse(time.strftime("%a %b %d 00:00:00 %Z %Y"))
	  
	  # format current time with full date if day has changed from last tick
	  if this_day != last_day
		strftime = time.strftime("%I:%M%p\n %b %d") # ex. 12:34pm\n Jan 09 
	  else
		strftime = time.strftime("%I:%M%p") # ex. 12:34pm
	  end
	  
	  # remove leading zero (0) JESUS FUCK RUBY CAN SUCK MY GODDAMN COCK WHY WAS THIS SO FUCKING HARD?!
	  strftime = strftime.reverse.chomp("0").reverse
	  
	  # update last day
	  last_day = this_day
	  
	  # yield formatted time
	  yield i, strftime
	end
  end
  
  def all_strftime
	strftimes = Array.new(@ticks)
	each_tick_with_strftime do |i, strftime|
	  strftimes[i] = strftime
	end
	strftimes 
  end
  
end