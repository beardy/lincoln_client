class BaseGraph
  # title should be unique - for the top part of the sliders
  # width and height used for display
  attr_accessor :title, :width, :height
  
  # options could have
  # :width & :height
  def initialize(title, options = {})
    @title = title
    @width = options[:width] || 200
    @height = options[:height] || 250
  end
  
  # bring in the raw data and process it as needed
  def preprocess(raw_data)
    puts "Should overwrite preprocess method"
  end
  
  
  # we have access to the builder class,
  # so we can create and use the builder here.
  # perhaps saving the resulting graph in @ofc
  def postprocess()
    puts "Should overwrite postprocess method"
  end
  
  # Get the raw ofc graph out of our graph shell
  def ofc_graph
    @ofc
  end
  
  # converts the title into a unique name
  def name
    self.title.lowercase.split(' ').join("_")
  end
end