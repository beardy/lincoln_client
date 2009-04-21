module BeardGraph
  #
  # Distribution of Top Ports by Data Size (Group Details)
  #
  class TopGraphGroupDetailsPorts < TopGraphGroupDetails
    
    def preprocess(groups)
	  @top_count = 5
	  
	  # convert RGB to HSL
	  hsl = Color.rgb_to_hsl(Color.hex_to_rgb(groups.first.color))
	  
      # initialize graph data
	  @data.num_values = 0
	  @data.elements["All"] = GraphElement.new("All", @data.num_values)
	  @data.elements["All"].colors = (0..@top_count).to_a.map { |i| "##{Color.rgb_to_hex(Color.hsl_to_rgb([hsl[0], hsl[1], 0.3 + i * 0.1]))}" }
	  
      # initialize all data
      @all_data = {}
	  @all_data = Hash.new(0)
    end
    
    def postprocess(groups)
      # sum all data
      all_sum = @all_data.inject(0){ |sum, x| sum + x[1] }
	  
	  # ignore empty data sets
	  unless all_sum == 0
		# initialize top data values
		@top_count.times do |i|
		  # find max (by value)
		  max = @all_data.max{|a,b| a[1] <=> b[1]}
		  unless max.nil? or max.last == 0
			@data.elements["All"].values << GraphValue.new(max.last, "#{max.first}")
			@data.elements["All"].values[i].label = "#{max.first} (#{max.last * 100 / all_sum}%)"
			@all_data[max.first] = 0
		  end
		end
		
		# sum other data
		other_sum = @all_data.inject(0){ |sum, x| sum + x[1] }
		@data.elements["All"].values << GraphValue.new(other_sum, "Other")
		@data.elements["All"].values.last.label = "Other (#{other_sum * 100 / all_sum}%)"
	  end
	  
      # update graph data
      @data.num_values = @data.elements["All"].values.length
      
      # scale data values 
      label = scale_data
      
      # initialize data tooltips
      @data.each_value do |v|
        v.tooltip += sprintf("<br>%6.6f #{label}", v.value)
      end
	  
	  # update for empty graphs....
	  if @data.num_values == 0
		@data.elements["All"].values << GraphValue.new(1.0, "Other")
		@data.elements["All"].values.last.label = "Other (0%)"
		@data.elements["All"].values.last.tooltip = "Other" + sprintf("<br>%6.6f #{label}", 0)
		@data.num_values = 1
	  end
    end
    
    def generate_graph
      builder = PieGraphBuilder.new(@data)
      @graph = builder.build
    end
	
  end
end