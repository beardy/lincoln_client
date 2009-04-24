module BeardGraph
  #
  # Distribution of Daily Traffic by Data Size
  #
  class ScatterGraphDailyTraffic < BaseGraph
    attr_accessor :top_count
    
    def initialize(title, time_range, options = {})
      super(title, options)
      @time_range = time_range
	  @top_count = 10
    end
    
    def preprocess(groups)
	  # initialize graph properties
      @dot_size_max = 20
      @dot_size_min = 5
      @dot_size_range =@dot_size_max - @dot_size_min
      
      # initialize graph data
      @data.num_values = 0
      @data.elements["All"] = GraphElement.new("All", 0)
	  @data.elements["All"].name = ""
      @data.elements["All"].dot_size = @dot_size_min
      @data.elements["All"].color = "#000000"
      
      # initialize all group data
      @all_data = Hash.new(0)
      
      # initialize time information
      @start_day = Time.parse(@time_range.start_time.strftime("%a %b %d 00:00:00 %Z %Y"))
      @end_day = Time.parse(@time_range.end_time.strftime("%a %b %d 00:00:00 %Z %Y")) + 1.day
      @days = ((@end_day - @start_day) / 1.day).round

      @start_hour = Time.parse(@time_range.start_time.strftime("%a %b %d %H:00:00 %Z %Y"))
      @end_hour = Time.parse(@time_range.end_time.strftime("%a %b %d %H:00:00 %Z %Y")) + 1.hour
      @hours = ((@end_hour - @start_hour) / 1.hour).round

      @start_day_hour = @time_range.start_time.hour
      @end_day_hour = @time_range.end_time.hour
    end
	
    def process(group, stream, window)
      # find hour indexes
      start_hour_index = ((Time.parse(window.start_time.strftime("%a %b %d %H:00:00 %Z %Y")) - @start_hour) / 1.hour).round
      end_hour_index = ((Time.parse(window.end_time.strftime("%a %b %d %H:00:00 %Z %Y")) - @start_hour) / 1.hour).round
      
      # aggregate data values
      if start_hour_index == end_hour_index
        @all_data[start_hour_index] += window.size_packets_all
      else
        start_hour_ratio = (@start_hour + (start_hour_index + 1).hour - window.start_time) / (window.end_time - window.start_time)
        @all_data[start_hour_index] += window.size_packets_all * start_hour_ratio
        @all_data[end_hour_index] += window.size_packets_all * (1 - start_hour_ratio)
      end
    end
    
    def postprocess(groups)
      # initialize top data values
      @top_count.times do |i|
        # find max (by value)
        max = @all_data.max { |a,b| a[1] <=> b[1] }
        unless max.nil? or max.last == 0
		  @data.elements["All"].values << GraphValue.new(max.last, max.first)
          @all_data[max.first] = 0
        end
      end
	  
      # update graph data
      @data.num_values = @data.elements["All"].values.length
      
	  unless @data.elements["All"].values.empty?
		# scale data values 
		label = scale_data
		
		# initialize data for dot sizes
		value_max = @data.elements["All"].values.max{ |a,b| a.value <=> b.value}.value
		value_min =  @data.elements["All"].values.min{ |a,b| a.value <=> b.value}.value
		value_range = value_max - value_min
		value_range = (value_range == 0) ? 1.0 : value_range
		  
		# initialize true graph data values
		@data.each_value do |v|
		  # temp values
		  hour_index = v.tooltip
		  data_value = v.value
		  data_time = @start_hour + hour_index.hour
		  # calculate data position
		  x = @start_day_hour + hour_index
		  y = x % 24
		  # init values
		  v.value = [x, y]
		  v.tooltip = data_time.strftime("%a %b %d %I:00%p")
		  v.tooltip += sprintf("<br>%6.6f #{label}", data_value)
		  v.dot_size = (((data_value - value_min) / (value_range * 1.0)) * @dot_size_range + @dot_size_min).round
		end
	  end
    end
    
    def generate_graph
	  @data.y_labels = Array.new(25, "")
	  @data.y_labels[0] = "12:00AM"
	  @data.y_labels[4] = " 4:00AM"
	  @data.y_labels[8] = " 8:00AM"
	  @data.y_labels[12] = "12:00PM"
	  @data.y_labels[16] = " 4:00PM"
	  @data.y_labels[20] = " 8:00PM"
	  @data.y_labels[24] = "12:00AM"
	  
	  @data.x_labels = Array.new(@days * 24 + 1, "")
	  [@days + 1, 4].min.times do |i|
		hour_index = i * (@days / 4.0).ceil * 24
		@data.x_labels[hour_index] = (@start_day + hour_index.hour).strftime("%b %d")
	  end
	  
      builder = ScatterGraphBuilder.new(@data, @days)
      @graph = builder.build
    end
    
  end
end