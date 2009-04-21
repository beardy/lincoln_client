module BeardGraph
  #
  # Timeline of Network Traffic by Packet Counts (Group Details)
  #
  class TimelineGraphGroupDetailsPacketCount < TimelineGraphGroupDetails
    
    def process(group, window)
      # aggregate data values
      @time_range.each_increment_with_ratio(window.start_time, window.end_time) do |increment_index, increment_ratio|
        @data.elements["Incoming"].values[increment_index].value += window.num_packets_incoming * increment_ratio
		@data.elements["Outgoing"].values[increment_index].value += window.num_packets_outgoing * increment_ratio
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
