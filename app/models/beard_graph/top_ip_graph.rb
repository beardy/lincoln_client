module BeardGraph
  class TopIPGraph < TopGraph
    
    def preprocess
      @top_count = 10
      @data_values ||= {:ip_incoming_size => "Incoming", :ip_outgoing_size => "Outgoing"}
    end
    
    def process
      each_data_component_with_values do |data_component, values|
        @top_count.times do |count|
          max = values.max{|a,b| a[1] <=> b[1]}
          unless max.nil? or max.last == 0
            data_component[:values][count] = max.last
            data_component[:keys][count] = "#{max.first}"
            # Then we have this line:
            values[max.first] = 0
          end #unless
        end #times
      end #each data_component
    end #process
    
    def postprocess
     scale, label = determine_scale_and_label
     	# update values
     	each_processed_data_value do |v| 
     	  v[:values].map! { |n| n / scale }
     	  v[:keys] = v[:keys].zip(v[:values]).map { |k, v| sprintf("#{k}<br>%6.6f #{label}", v) }
     	end #each_value
    end #postprocess
    
    def generate_graph
      builder = GraphBuilder.new(:bar, self.processed_data_for_builder)
      @graph = builder.build
    end #generate_graph
    
  end #top_ip_graph
end #beard_graph