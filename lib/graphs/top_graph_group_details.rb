module BeardGraph
  #
  # Distribution of Top Categories (Group Details)
  #
  class TopGraphGroupDetails < BaseGraphGroupDetails
    attr_accessor :top_count
    
    def initialize(title, options = {})
	  super(title, options)
	  @top_count = 10
    end
	
  end
end
