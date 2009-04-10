module BeardGraph
  class TopPortGraph < TopGraph
    
    def preprocess
      @top_count = 5
      @data_values ||= {:port_outgoing_size => "Outgoing"}
    end #preprocess
    
    def process
      each_data_component_with_values do |data_component, values|
                                     
        all_sum = values.inject(0){|sum,n| sum + n[1]}
          self.top_count.times do |count|
            max = values.max{|a,b| a[1] <=> b[1]}
            unless max.nil? or max.last == 0
              data_component[:values][count] = max.last
              data_component[:keys][count] = "#{max.first}"
              data_component[:x_labels][count] = "#{max.first} (#{if all_sum == 0 then 0 else (max.last * 100 / all_sum).round end}%)"
              # Then we have this line:
                values[max.first] = 0
              #     but we really don't want to delete data from the @data now              
            end #unless
          end #times
          
          # get all other sum
          other_sum = values.inject(0){|sum,n| sum + n[1]}
          data_component[:values].push(other_sum)
          data_component[:x_labels].push("Other (#{if all_sum == 0 then 0 else (other_sum * 100 / all_sum).round end}%)")          
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
      builder = GraphBuilder.new(:pie, self.processed_data_for_builder)
      @graph = builder.build
    end #generate_graph
    
  end #class
end #module
