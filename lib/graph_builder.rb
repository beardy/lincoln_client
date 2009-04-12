class GraphBuilder
  include OpenFlashChart
  # TODO: Find better way for automatic color generation
  COLORS = %w[#1C6569 #9C1146 #420E82 #F56A2A #994B25 #8E83D4 #F0A729]
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
    # puts "chart: "+@chart.inspect
    @chart
  end
  
  def populate_graph
    max = 0.0
    color_index = 0
	
    @data.each do |key, data|
      # initialize color from default theme
	  color = find_color(color_index)
      color_index += 1
	  
	  # initialize chart element
      element = find_element_type(@type)
      element.text = key.to_s
      element.width = @options[:line_width]
      element.dot_size = @options[:dot_size]
	  element.colour = color
	  element.colours = COLORS
      element.fill = color
      element.fill_alpha = 1
    
      # initialize element values (with tooltips and x-axis labels)
      if data.has_key?(:keys) and data.has_key?(:x_labels)
        element.values = data[:values].zip(data[:keys], data[:x_labels]).map{|x, y, z| 
		  find_value_type(@type, {:color => color, :value => x, :key => y, :x_label => z}) }
	  # initialize element values (with tooltips)
	  elsif data.has_key?(:keys)
	    element.values = data[:values].zip(data[:keys]).map{|x, y| 
		  find_value_type(@type, {:color => color, :value => x, :key => y}) }
      else
        element.values = data[:values]
      end
      
      @chart.add_element(element)
	  
	  # update max value
      max = max < data[:values].max ? data[:values].max : max
    end
    
    y = YAxis.new
    y.set_range(0, max, max / 10)
    @chart.y_axis = y
  end
  
  def configure
    if @options[:title]
	  title = Title.new(options[:title])
	  title.set_style('{font-size: 20px;}')
	  @chart.set_title(title)
	end
    if @options[:legend]
      y_legend = YLegend.new(options[:legend])
      y_legend.set_style('{font-size: 20px; color: #770077}')
      @chart.set_y_legend(y_legend)
    end
  end
  
  def find_element_type(type)
    element = case type
      when :line : LineDot.new
      when :area : AreaHollow.new
	  when :bar : Bar.new
	  when :pie : Pie.new
      else LineDot.new
    end
    element
  end
  
  def find_value_type(type, options)	
    element = case type
      when :line : DotValue.new(options[:value], options[:color])
      when :area : DotValue.new(options[:value], options[:color])
	  when :bar : BarValue.new(options[:value])
	  when :pie : PieValue.new(options[:value], options[:x_label])
      else DotValue.new(options[:value], options[:color])
	end
    element.tooltip = options[:key]
    element
  end
  
  def find_color(index)
    COLORS[index]
  end
end
