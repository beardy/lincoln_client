module BeardGraph
  class TopGraph < BaseGraph
    attr_accessor :top_count
    
    def preprocess
      @top_count = 5
    end
      
    def each_data_component_with_values
      @processed_data = Hash.new
      
      each_group do |group|
        @processed_data[group] = Hash.new {|h,k| h[k] = Hash.new() }
        # each data_value is a particular aggregation in our @data - like :incoming or :outgoing
        each_data_value do |data_value, data_value_name|
           @processed_data[group][data_value_name][:values]  = Array.new(self.top_count, 0)
           @processed_data[group][data_value_name][:keys]  = Array.new(self.top_count, 0)
           @processed_data[group][data_value_name][:x_labels]  = Array.new(self.top_count, 0)
           
          yield @processed_data[group][data_value_name], @data[group][data_value]
          puts @processed_data[group][data_value_name].inspect
        end
      end
    end #each_data_component    
    
    # Work around for current limitations of graph builder - 
    #  or just to make graph builders job easier
    def processed_data_for_builder
      unless @data_for_builder
        processed_data = nil
        if self.groups.size == 1        
          processed_data = @processed_data[self.groups[0]]
        else
          each_group do |group|
            @processed_data[group] = @processed_data[group].shift[1]
          end
          processed_data = @processed_data
        end
        @data_for_builder = processed_data
      end
      @data_for_builder
    end
    
    
    private
    
    def determine_scale_and_label
      max = 0
      each_group do |group|
        sub_max = @processed_data[group].inject(0) { |max, n| [max, n[1][:values].max].max }
        max = sub_max > max ? sub_max : max
      end
      
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