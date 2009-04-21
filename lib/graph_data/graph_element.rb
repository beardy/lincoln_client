class GraphElement
  attr_accessor :name, :values, :color, :colors, :dot_size, :line_width

  def initialize(name, size = 0)
	@name = name
	@values = Array.new(size) { GraphValue.new(0) }
	@color = ""
	@colors = ""
	@dot_size = ""
	@line_width = ""
  end
end