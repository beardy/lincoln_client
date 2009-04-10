module BeardGraph
  class BaseGraph
    # title should be unique - for the top part of the sliders
    # width and height used for display
    attr_accessor :title, :width, :height, :processed_data, :data, :graph
    # the values we want out of the data
    attr_accessor :data_values
    
  
    # options could have
    # :width & :height
    def initialize(title, options = {})
      @title = title
      @width = options[:width] || 200 # defaults to the small graphs
      @height = options[:height] || 250
    end
      
    # Should be overridden in subclass if preprocessing is necessary
    def preprocess
    end
  
    # Should be overridden in subclass if processing is necessary
    def process
    end
  
    # Should overwrite in subclass
    def postprocess
    end
  
    # Should overwrite in subclass
    def generate_graph  
    end
    
    # holds which groups (or group) the graph will work on
    def groups=(groups)
      @groups = groups.to_a
    end
    
    def each_group
      @groups ||= 0
      @groups.each {|group| yield group}
    end
    
    def each_data_value
      @data_values = @data_values
      @data_values.each {|data_value, name| yield data_value, name}
    end    
    
  
    # converts the title into a unique name
    def name
      self.title.downcase.split(' ').join("_")
    end
    
    def ofc_graph
      @graph
    end
    
    def display
      self.ofc_graph.js_open_flash_multi_chart_object(self.name, self.height, self.width)
    end
    
  end
end