module BeardGraph
  #
  # Base Graph (provides abstract functions and generic graph functionality)
  #
  class BaseGraph
    # title should be unique - for the top part of the sliders
    # width and height used for display
    attr_accessor :title, :width, :height, :data, :graph
    
    # options could have
    # :width & :height
    def initialize(title, options = {})
      @title = title
      @width = options[:width] || 250 # defaults to the small graphs
      @height = options[:height] || 200
      @data = GraphData.new
    end
      
    # Should be overridden in subclass if preprocessing is necessary
    def preprocess(groups)
    end
  
    # Should be overridden in subclass if data aggregation is necessary
    def process(group, stream, window)
    end
  
    # Should overwrite in subclass if postprocessing is necessary
    def postprocess(groups)
    end
  
    # Should overwrite in subclass
    def generate_graph
    end
    
    # converts the title into a unique name
    def name
      self.title.downcase.split(' ').join("_")
    end
    
    def ofc_graph
      @graph
    end
    
    def display
      self.ofc_graph.js_open_flash_multi_chart_object(self.name, self.width, self.height)
    end
    
    protected    

    def scale_data
      # find max data value
      max = @data.elements.values.inject(0) { |m, e| [m, e.values.inject(0) { |m, v| [m, v.value].max }].max }
      
      # calculate appropriate data scale (and corresponding label)
      scale = 1.0
      labels = %w[B KB MB GB TB PB EB]
      label = labels[0]
      labels.each do |n|
        if (max / (scale * 1024)) >= 1 
          scale *= 1024
        else 
          label = n
          break
        end
      end
      
      # scale data values
      @data.each_value do |v|
        v.value = v.value / scale
      end
      
      # return label
      label
    end
    
    # normalize data values
    def normalize_data
      # sum data values
      sum = @data.elements.values.inject(Array.new(@data.num_values, 0)) { |sum, e| e.values.zip(sum).map{ |v, sum| v.value + sum } }
      
      # normalize data values
      @data.each_value_with_index do |v, i|
        v.value = (sum[i] == 0) ? 0 : v.value / (sum[i] * 1.0)
      end
    end
    
    # cumulative sum of data values
    def cumsum_data
      @data.elements.values.reverse.inject(Array.new(@data.num_values, 0)) { |sum, e| e.values.zip(sum).map{ |v, sum| v.value += sum } }
    end
	
  end
end