module BeardGraph
  #
  # Distribution of Top Incoming Ports by Data Size (Group Details)
  #
  class TopGraphGroupDetailsPortsIncoming< TopGraphGroupDetailsPorts
    
    def process(group, stream, window)
	  # aggregate data values
	  @all_data[stream.port_incoming] += window.size_packets_incoming
    end
	
  end
end