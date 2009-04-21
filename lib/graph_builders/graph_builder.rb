class GraphBuilder
  include OpenFlashChart
  attr_accessor :title
  
  def initialize(data)
    @data = data
    @graph = OpenFlashChart.new
  end

  def build
    configure
    populate_graph
    @graph
  end

  # private helper methods
  private
  
  def configure
    # initialize dot size
    if @data.dot_size.nil?
      @data.dot_size = 5
    end
    
    # initialize line width
    if @data.line_width.nil?
      @data.line_width = 2
    end
    
    # initialize graph title
    if not @data.title.nil?
      title = Title.new(@data.title)
      title.set_style('{font-size: 20px; color: #770077}')
      @graph.set_title(title)
    end
    
    # initialize graph legend
    if not @data.legend.nil?
      y_legend = YLegend.new(options[:legend])
      y_legend.set_style('{font-size: 20px; color: #770077}')
      @graph.set_y_legend(y_legend)
    end
    
	# intialize x-axis labels
	if not @data.x_labels.nil?
	  x_labels = XAxisLabels.new
	  x_labels.labels = @data.x_labels.map { |x| XAxisLabel.new(x, '#000000', 8, ""); }
	  x = XAxis.new
	  x.set_labels(x_labels)
	  @graph.x_axis = x
	end
	
	# initialize y-axis labels
	y = YAxis.new
	if not @data.y_labels.nil?
	  y.set_labels(@data.y_labels)
	end
	# initialize graph scale
    max = @data.elements.values.inject(0) { |m, e| [m, e.values.inject(0) { |m, v| [m, v.value].max }].max }
	if max == 0
	  y.set_range(0, 1, 1)
	else
	  y.set_range(0, max, max / 10)
	end
    @graph.y_axis = y
  end

  def populate_graph
    # add each data element to the open flash chart graph
    @data.each_element do |e|
      
      # initialize graph element
      graph_element = get_graph_element(e)
      init_graph_element(graph_element, e)
      
      # initialize graph values
      graph_element.values = e.values.map do |v|
        gv = get_graph_value(v)
        init_graph_value(gv, e, v)
        gv
      end
      
      # add element to graph
      @graph.add_element(graph_element)
    end
  end
  
  # protected abstract methods
  def get_graph_element(e)
  end
  
  def get_graph_value(v)
  end
  
  def init_graph_element(ge, e)
    # initialize line width 
    if not e.line_width == ""
      ge.width = e.line_width
    else
      ge.width = @data.line_width
    end
    
    # initialize dot size
    if not e.dot_size == ""
      ge.dot_size = e.dot_size
    else
      ge.dot_size = @data.dot_size
    end
    
    # initialize element name
    if not e.name.empty?
      ge.text = e.name
    end
    
    # initialize color
    if not e.color.empty?
      ge.colour = e.color
	  ge.fill = e.color
    end
    ge.fill_alpha = 1
	
	# initialize legend size
	ge.font_size = 12
  end

  def init_graph_value(gv, e, v)
    # intialize tooltip
    if not v.tooltip.empty? 
      gv.tooltip = v.tooltip
    end
    
    # initialize color
    if not v.color.empty?
      gv.colour = v.color
    elsif not e.color.empty?
      gv.colour = e.color
    end
  end
  
end
