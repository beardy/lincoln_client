module BeardGraph
  #
  # Distribution of Top Groups by Data Size (All Groups)
  #
  class TopGraphAllGroupsGroups < TopGraphAllGroups
    
    def preprocess(groups)
      @top_count = 10
      
      # initialize graph data
      @data.num_values = 0
      @data.elements["All"] = GraphElement.new("All", 0)
      @data.elements["All"].colors = groups.map { |g| "##{g.color}" }
      
      # initialize all group data
      @all_data = Hash.new(0)
    end
    
    def process(group, stream, window)
      # aggregate data values
      @all_data[group.name] += window.size_packets_all
    end
    
    def postprocess(groups)
      # sum all data
      all_sum = @all_data.inject(0){ |sum, x| sum + x[1] }
      
      # initialize top data values
      @top_count.times do |i|
        # find max (by value)
        max = @all_data.max{|a,b| a[1] <=> b[1]}
        unless max.nil? or max.last == 0
		  @data.elements["All"].values << GraphValue.new(max.last, "#{max.first}")
          @data.elements["All"].values[i].label = "#{max.first}\n(#{max.last * 100 / all_sum}%)"
          @all_data[max.first] = 0
        end
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
