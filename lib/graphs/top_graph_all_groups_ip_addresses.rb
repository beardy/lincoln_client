module BeardGraph
  #
  # Distribution of Top IP Addresses by Data Size (All Groups)
  #
  class TopGraphAllGroupsIPAddresses < TopGraphAllGroups
    
    def preprocess(groups)
      @top_count = 10
      @data.num_values = @top_count
	  
	  # initialize graph data
	  super(groups)
      
      # initialize all group data
      @all_data = {}
	  @all_data = Hash.new { |hash, key| hash[key] = Hash.new(0) }
    end
    
    def process(group, stream, window)
      # aggregate data values
	  @all_data[group.name][stream.ip_incoming] += window.size_packets_incoming
	  @all_data[group.name][stream.ip_outgoing] += window.size_packets_outgoing
    end
    
    def postprocess(groups)
      # initialize top data values and tooltips
      groups.each do |group|
        @top_count.times do |i|
          # find max (by value)
          max = @all_data[group.name].max{|a,b| a[1] <=> b[1]}
          unless max.nil? or max.last == 0
            @data.elements[group.name].values[i].value = max.last
			if Stream.host_name(max.first) == max.first
			  @data.elements[group.name].values[i].tooltip = "#{max.first}"
			else
			  @data.elements[group.name].values[i].tooltip = "#{Stream.host_name(max.first)} (#{max.first})"
			end
            @all_data[group.name][max.first] = 0
          end
        end
      end
      
      # scale data values 
      label = scale_data
      
      # initialize data tooltips
      @data.each_value do |v|
        v.tooltip += sprintf("<br>%6.6f #{label}", v.value)
      end
    end
    
    def generate_graph
      builder = BarGraphBuilder.new(@data)
      @graph = builder.build
    end
    
  end
end