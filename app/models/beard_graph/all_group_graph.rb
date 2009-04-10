module BeardGraph
  class AllGroupGraph < TopGraph
    
    def preprocess
      # unnecessary
      @top_count = 5
      @data_values ||= {:all_size => "All"}
    end #preprocess
    
    def process
      each_data_component_with_values do |data_component, value|
        data_component[:values] = value
        all_sum = data_component[:values]
        data_component[:x_labels] = @data.zip(data_component[:values]).map{|x, y| "#{x[0]} (#{if all_sum == 0 then 0 else (y * 100 / all_sum).round end}%)"}
      end
    end #process
    
    def postprocess
      scale, label = determine_scale_and_label
      # update values
      each_processed_data_value do |v| 
        v[:values].map! { |n| n / scale }
        v[:keys] = v[:values].map { |n| sprintf("%6.6f #{label}", n) }
      end
    end #postprocess
    
    def generate_graph
      # configure graph
      builder = GraphBuilder.new(:pie, self.processed_data)
      @graph = builder.build
    end #generate_graph
    
  end #class
end #module
