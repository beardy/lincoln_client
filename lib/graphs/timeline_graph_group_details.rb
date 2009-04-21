module BeardGraph
  #
  # Timeline of Network Traffic (Group Details)
  #
  class TimelineGraphGroupDetails < BaseGraphGroupDetails
  
    def initialize(title, time_range, options = {})
      super(title, options)
      @time_range = time_range
      @time_range.ticks = 10
    end
	
    def preprocess(groups)
      @data.num_values = @time_range.ticks
	  
	  # initialize graph data
	  super(groups)
	end
	
    def generate_graph
	  # initialize x-labels with formatted times
	  @data.x_labels = @time_range.all_strftime()
	  @data.x_labels_rotate = "vertical"
    end
	
  end
end
