class GraphBuilder
  
  attr_accessor :title, :options
  
  # type is a symbol which indicates what type of chart you are making
  # Possible types:
  # :line => create line graph
  # 
  # data
  # data is assumed to be a hash, where the key will be 
  #  converted into a string  using its 'to_s' method to be used as the title for each
  #  component of the graph.
  #  if the key has a 'color' method, then that will be used as the color of the graph 
  #  component.
  #  The values of the hash will be used as the values of the particular chart element
  #   So make it an array if its a line chart
  # 
  # Possible options:
  # :title => string representing the title of the chart
  # :legend => y-axis legend string
  # :line_width => size of line
  # :dot_size => size of dots
  def initialize(type, data, options = {})
    options = {
			:line_width => 2, 
			:dot_size => 5,
		}.merge(options)
		@type = type
		@chart = OpenFlashChart.new
    @data = data
    @options = options
  end
  
  def build
    configure
    populate_graph
    @graph
  end
  
  def populate_graph
    max = 0
    data.each do |key, value|
      element = find_type(@type)
      element.text = key.to_s
      element.width = @options[:line_width] if element.respond_to? :width
      element.dot_size = @options[:dot_size] if element.respond_to? :dot_size
      if key.respond_to? color
        element.color = '#'+key.color
      else
        element.color = '#356aa0'
      end
      element.values = value
      
      @graph.add_element(element)
      max = max < value.max ? value.max : max
    end
    
    y = YAxis.new
    y.set_range(0, max, max / 10)
    @chart.y_axis = y
  end
  
  def configure
    @chart.set_title(options[:title]) if @options[:title]
    if @options[:legend]
      y_legend = YLegend.new(options[:legend])
      y_legend.set_style('{font-size: 20px; color: #770077}')
      @chart.set_y_legend(y_legend)
    end
  end
  
  def find_type(type)
    element = case type
      when :line : LineDot.new
      else LineDot.new
    end
    element
  end
end