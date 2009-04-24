module BeardGraph
  #
  # Timeline of Network Traffic by Data Sizes (Group Details)
  #
  class TimelineGraphGroupDetailsDataSize < TimelineGraphGroupDetails
  
    def process(group, stream, window)
      # aggregate data values
      @time_range.each_increment_with_ratio(window.start_time, window.end_time) do |increment_index, increment_ratio|
        @data.elements["Incoming"].values[increment_index].value += window.size_packets_incoming * increment_ratio
		@data.elements["Outgoing"].values[increment_index].value += window.size_packets_outgoing * increment_ratio
      end
    end
  
    def postprocess(groups)
      # scale data values 
      label = scale_data
      # initialize data tooltips
      @data.each_value do |v|
        v.tooltip = sprintf("%6.6f #{label}", v.value)
      end
    end
  
    def generate_graph
	  # initialize x-labels
	  super
	  # build new graph
      builder = LineGraphBuilder.new(@data)
      @graph = builder.build
    end
    
  end
end