class GraphValue
  attr_accessor :value, :tooltip, :color, :label, :dot_size

  def initialize(value = 0, tooltip = "")
	@value = value
	@tooltip = tooltip
	@color = ""
	@label = ""
	@dot_size = ""
  end
  
end
