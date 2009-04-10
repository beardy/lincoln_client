module BeardGraph
  class TopIPGraph < BaseGraph
    # the values we want out of the data
    attr_accessor :data_values
    
    def preprocess
      @top_count = 10
      @data_values ||= {:ip_incoming_size => "Incoming", :ip_outgoing_size => "Outgoing"}
    end
    
    def process
        @processed_data = {}
        each_group do |group|
          # each data_value is a particular aggregation in our @data - like :incoming or :outgoing
          each_data_value do |data_value, data_value_name|
            # form a new entry in our processed data for this data value
            @processed_data[data_value_name] = {:values => Array.new(@top_count, 0), :keys => Array.new(@top_count, 0)}
          
            @top_count.times do |count|
              max = @data[group][data_value].max{|a,b| a[1] <=> b[1]}
              unless max.nil? or max.last == 0
                @processed_data[data_value_name][:values][count] = max.last
                @processed_data[data_value_name][:keys][count] = "#{max.first}"
                # Then we have this line:
                  @data[group][data_value][max.first] = 0
                #     but we really don't want to delete data from the @data now              
              end #unless
            end #times
          end #each data_value
        end #each group
    end #process
    
    def postprocess
     scale, label = determine_scale_and_label
     	# update values
     	@processed_data.each_value do |v| 
     	  v[:values].map! { |n| n / scale }
     	  v[:keys] = v[:keys].zip(v[:values]).map { |k, v| sprintf("#{k}<br>%6.6f #{label}", v) }
     	end #each_value
    end #postprocess
    
    def generate_graph
      builder = GraphBuilder.new(:bar, self.processed_data)
      @graph = builder.build
    end #generate_graph
    
    def each_data_value
      @data_values = @data_values
      @data_values.each {|data_value, name| yield data_value, name}
    end
    
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
  end #top_ip_graph
end #beard_graph