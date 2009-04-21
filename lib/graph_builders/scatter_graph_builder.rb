class ScatterGraphBuilder < GraphBuilder

  def initialize(data, days)
    super(data)
    @days = days
  end
  
  def configure
    x = XAxis.new
	# initialize x-axis scale
    x.set_range(0, @days * 24, (@days / 4.0).ceil * 24)
	# intialize x-axis labels
	if not @data.x_labels.nil?
	  x_labels = XAxisLabels.new
	  x_labels.labels = @data.x_labels.map { |label| XAxisLabel.new(label, '#000000', 8, ""); }
	  x.set_labels(x_labels)
	end
	@graph.x_axis = x

	y = YAxis.new
	# initialize y-axis scale
    y.set_range(0, 24, 4)
	# initialize y-axis labels
	if not @data.y_labels.nil?
	  y.set_labels(@data.y_labels)
	end
    @graph.y_axis = y
  end

  def get_graph_element(e)
    ge = Scatter.new(e.color, e.dot_size)  # color, dot size
    ge
  end

  def get_graph_value(v)
    gv = ScatterValue.new(*v.value)
    gv.dot_size = v.dot_size
    gv
  end

end
