module BeardGraph
  #
  # Distribution of Top Outgoing Ports by Data Size (Group Details)
  #
  class TopGraphGroupDetailsPortsOutgoing < TopGraphGroupDetailsPorts
    
    def process(group, window)
	  # aggregate data values
	  @all_data[window.stream.port_outgoing] += window.size_packets_outgoing
    end
    
  end
end