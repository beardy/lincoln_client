module BeardGraph
  #
  # Timeline of Network Traffic by Normalized Data Sizes (All Groups)
  #
  class TimelineGraphAllGroupsDataSizeNormalized < TimelineGraphAllGroups
  
    def process(group, stream, window)
      # aggregate data values
      @time_range.each_increment_with_ratio(window.start_time, window.end_time) do |increment_index, increment_ratio|
        @data.elements[group.name].values[increment_index].value += window.size_packets_all * increment_ratio
      end
    end
  
    def postprocess(groups)
      # normalize data values
      normalize_data
      # initialize data tooltips
      @data.each_value do |v|
        v.tooltip =  "#{(v.value * 100).round}%"
      end
      # cumulative sum data values
      cumsum_data
    end
  
    def generate_graph
	  # initialize x-labels
	  super
	  # build new graph
      builder = AreaGraphBuilder.new(@data)
      @graph = builder.build
    end
    
  end
end
