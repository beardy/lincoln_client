class GraphsController < ApplicationController
  GRAPH_HOOKS = %w(preprocess process postprocess generate_graph)
  
  def index
    @graph_groups = detail_graphs
    @graph_top_ip_by_data_size = open_flash_chart_object(250, 200, url_for(:controller => 'groups', :action => "top_ip_by_data_size", :id => Group.find(:first).id, :only_path => true))
  end
  
  # will create an array of TrafficTimelineGraphs that hold the graphs to be displayed at the top portion of the page
  def timeline_graphs
    # figure out which group / groups are going to be generated
    # acquire data for group set from database
    # create instances of the TrafficTimelineGraphs to populate 
    # populate accordingly
    # return array of graphs
  end
  
  # will return an array of arrays for the mid-page graphs each inner-array will be a column
  def detail_graphs
    selected_groups = Group.find(:first).to_a
    graph_groups = create_detail_graphs(selected_groups)
    graph_groups = generate_detail_graphs(graph_groups, selected_groups)
    graph_groups
  end
  
  def create_detail_graphs(groups)
    graph_groups = []
    a = BeardGraph::TopIPGraph.new("Test Top IP")
    b = BeardGraph::TopPortGraph.new("test top port")
    graph_groups << [a] << [b]
    
    group_names = groups.map {|g| g.name}
    graph_groups.each do |graphs|
      graphs.each do |graph|
        graph.groups = group_names
      end
    end
    
  end
    
  # graph_groups is an array of arrays of our shell graphs
  def generate_detail_graphs(graph_groups, selected_groups)
    # generate data
    data = self.aggregate_data(selected_groups)
    
    # populate graphs with data
    graph_groups.each do |graphs|
      graphs.each do |graph|
        graph.data = data
      end
    end
    
    # call each hook for each graph
    GRAPH_HOOKS.each do |hook|
      graph_groups.each do |graphs|
        graphs.each do |graph|
          graph.send(hook)
        end
      end
    end
    graph_groups
  end
  
  def aggregate_data(groups)
    puts groups.inspect
    data = {}
    groups.to_a.each do |group|
      data[group.name] = Hash.new {|hash, key| hash[key] = Hash.new(0)}
      streams = Stream.relevant_streams(@time_range, group, @global_rule)
      puts "STREAM SIZE: "+streams.size.to_s
      streams.each do |stream|
        stream.windows.each do |window|
          data[group.name][:ip_incoming_size][stream.ip_incoming] += window.size_packets_incoming
          data[group.name][:ip_incoming_num][stream.ip_incoming] += window.num_packets_incoming
          data[group.name][:ip_outgoing_size][stream.ip_outgoing] += window.size_packets_outgoing
          data[group.name][:ip_outgoing_num][stream.ip_outgoing] += window.num_packets_outgoing
          
          data[group.name][:port_incoming_size][stream.port_incoming] += window.size_packets_incoming
          data[group.name][:port_incoming_num][stream.port_incoming] += window.num_packets_incoming
          data[group.name][:port_outgoing_size][stream.port_outgoing] += window.size_packets_outgoing
          data[group.name][:port_outgoing_num][stream.port_outgoing] += window.num_packets_outgoing
        end
      end
    end
    data
  end
  
end
