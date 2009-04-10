module BeardGraph
  class TopGraph < BaseGraph
    
    def each_max
      each_group do |group|
        # each data_value is a particular aggregation in our @data - like :incoming or :outgoing
        each_data_value do |data_value, data_value_name|
          # form a new entry in our processed data for this data value
          @processed_data[data_value_name] = {:values => Array.new(@top_count, 0), :keys => Array.new(@top_count, 0)}
        
          @top_count.times do |count|
            max = @data[group][data_value].max{|a,b| a[1] <=> b[1]}
            unless max.nil? or max.last == 0
            end #unless
          end #times
        end #each data_value
      end #each group      
    end
        
  end
end