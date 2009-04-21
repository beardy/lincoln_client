class GraphData
  attr_accessor :elements, :num_values, :title, :legend, :x_title, :y_title, :x_labels, :x_labels_rotate, :y_labels, :dot_size, :line_width
  
  def initialize
    @elements = Hash.new
    @num_values = 0
    @title = nil
    @legend = nil
    @x_title = nil
    @y_title = nil
    @x_labels = nil
	@x_labels_rotate = nil
    @dot_size = nil
    @line_width = nil
  end
  
  def each_element
    @elements.values.each do |e|
      yield e
    end
  end
  
  def each_value
    each_element do |e|
      e.values.each do |v|
      yield v
      end
    end
  end
  
  def each_value_with_index
    each_element do |e|
      e.values.each_with_index do |v, i|
      yield v, i
      end
    end
  end
  
end