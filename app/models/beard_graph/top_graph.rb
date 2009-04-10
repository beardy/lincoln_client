module BeardGraph
  class TopGraph < BaseGraph
    attr_accessor :top_count
      
    def each_data_component_with_values
      @processed_data = Hash.new {|h,k| h[k] = Hash.new()}
      
      each_group do |group|
        # each data_value is a particular aggregation in our @data - like :incoming or :outgoing
        each_data_value do |data_value, data_value_name|
          
           @processed_data[data_value_name][:values]  = Array.new
           @processed_data[data_value_name][:keys]  = Array.new
           @processed_data[data_value_name][:x_labels]  = Array.new
           
          yield @processed_data[data_value_name], @data[group][data_value]
          puts @processed_data[data_value_name].inspect
        end
      end
    end #each_data_value
    
    private
    
    def determine_scale_and_label
      max = @processed_data.inject(0) { |max, n| [max, n[1][:values].max].max }
      # scale data
      #  can we move this into a library or the graph builder or something?
      #  why such ugly code?
     	scale = 1
     	labels = %w[B KB MB GB TB PB EB]
     	label = labels[0]
     	labels.each { |n| if max / (scale * 1024) > 1 then scale *= 1024; label = n; else break end }
     	[scale, label]
    end #determine_scale_and_label
            
  end
end