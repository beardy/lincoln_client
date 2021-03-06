module BeardGraph
  #
  # Timeline of Network Traffic by Packet Counts (All Groups)
  #
  class TimelineGraphAllGroupsPacketCount < TimelineGraphAllGroups
    
    def process(group, stream, window)
      # aggregate data values
      @time_range.each_increment_with_ratio(window.start_time, window.end_time) do |increment_index, increment_ratio|
        @data.elements[group.name].values[increment_index].value += window.num_packets_all * increment_ratio
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
