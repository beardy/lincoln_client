module BeardGraph
  #
  # Distribution of Daily Traffic by Data Size (Group Details)
  #
  class TopGraphGroupDetailsDailyTraffic < ScatterGraphDailyTraffic
    
    def preprocess(groups)
	  super(groups)
      @data.elements["All"].color = "##{groups.first.color}"
    end
	
  end
end
