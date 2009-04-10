module BeardGraph
  class TopPortGraph < BaseGraph
    
    def preprocess
      @top_count = 5
      @data_values ||= {:port_outgoing_size => "Outgoing"}
    end #preprocess
    
    def process
      @processed_data = {}
      
      each_group do |group|
        # each data_value is a particular aggregation in our @data - like :incoming or :outgoing
        each_data_value do |data_value, data_value_name|
          all_sum = @data[group][data_value].inject(0){|sum,n| sum + n[1]}
          # form a new entry in our processed data for this data value
          @processed_data[data_value_name] = {:values => Array.new,
                                              :keys => Array.new,
                                              :x_labels => Array.new }
        
          @top_count.times do |count|
            max = @data[group][data_value].max{|a,b| a[1] <=> b[1]}
            unless max.nil? or max.last == 0
              @processed_data[data_value_name][:values][count] = max.last
              @processed_data[data_value_name][:keys][count] = "#{max.first}"
              @processed_data[data_value_name][:x_labels].push("#{max.first} (#{if all_sum == 0 then 0 else (max.last * 100 / all_sum).round end}%)")
              # Then we have this line:
                @data[group][data_value][max.first] = 0
              #     but we really don't want to delete data from the @data now              
            end #unless
          end #times
          
          # get all other sum
          other_sum = @data[group][data_value].inject(0){|sum,n| sum + n[1]}
          @processed_data[data_value_name][:values].push(other_sum)
          @processed_data[data_value_name][:x_labels].push("Other (#{if all_sum == 0 then 0 else (other_sum * 100 / all_sum).round end}%)")
          
          
        end #each data_value
      end #each group
    end #process
    
    def postprocess
      scale, label = determine_scale_and_label
      # update values
      @processed_data.each_value { |v| 
       v[:values].map! { |n| n / scale }
       v[:keys] = v[:values].map { |n| sprintf("%6.6f #{label}", n) }
      }
    end #postprocess
    
    def generate_graph
      builder = GraphBuilder.new(:pie, self.processed_data)
      @graph = builder.build
    end #generate_graph
    
  end #class
end #module
