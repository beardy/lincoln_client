class GraphsController < ApplicationController
  GRAPH_HOOKS = %w(preprocess process postprocess generate_graph)
  
  def index
    @timeline_graphs = timeline_graphs(:all)
    @detail_graph_groups = detail_graphs(:all)
  end
  
  def show
    @timeline_graphs = timeline_graphs(params[:id])
    @detail_graph_groups = detail_graphs(params[:id])
  end
  
  # will create an array of TrafficTimelineGraphs that hold the graphs to be displayed at the top portion of the page
  def timeline_graphs(id)
    # figure out which group / groups are going to be generated
    # acquire data for group set from database
    # create instances of the TrafficTimelineGraphs to populate 
    # populate accordingly
    # return array of graphs
  end
  
  # will return an array of arrays for the mid-page graphs each inner-array will be a column
  def detail_graphs(id)
    blank_groups = nil
    data = nil
    if id == :all
      selected_groups = Group.find(@selected_groups)
      data = aggregate_data(selected_groups)
      blank_groups = all_group_detail_graphs
    else
      selected_group = Group.find(id)
      selected_groups = selected_group.to_a
      data = aggregate_data(selected_groups)
      blank_groups = individual_group_detail_graphs
    end
    graph_groups = add_names(blank_groups, selected_groups)
    graph_groups = generate_detail_graphs(blank_groups, data)
    graph_groups
  end
  
  def individual_group_detail_graphs
    port_g = [BeardGraph::TopPortGraph.new("Top Incoming Ports", :values => {:port_incoming_size => "Incoming"})]
    port_g << BeardGraph::TopPortGraph.new("Top Outgoing Ports", :values => {:port_outgoing_size => "Outgoing"})
    
    ip_g =  [BeardGraph::TopIPGraph.new("Top IP Addresses", :values => {:ip_incoming_size => "Incoming", :ip_outgoing_size => "Outgoing"})]
    [port_g, ip_g]
  end
  
  def all_group_detail_graphs
    group_g = [BeardGraph::AllGroupGraph.new("Group Distributions", :values => {:all_size => "All"})]
    ip_g = [BeardGraph::TopIPGraph.new("Top IP Addresses", :values => {:ip_all_size => "All"})]
    # create instances of groups and add them to graph_groups
    [group_g,ip_g]
  end
  
  def add_names(blank_graphs, groups)
    group_names = groups.map {|g| g.name}
    blank_graphs.each do |graphs|
      graphs.each do |graph|
        graph.groups = group_names
      end
    end
    blank_graphs
  end
    
  # graph_groups is an array of arrays of our shell graphs
  def generate_detail_graphs(graph_groups, data)    
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
    data = {}
    groups.to_a.each do |group|
      data[group.name] = Hash.new {|hash, key| hash[key] = Hash.new(0)}
      data[group.name][:all_size] = 0
      data[group.name][:all_num] = 0
      streams = Stream.relevant_streams(@time_range, group, @global_rule)
      puts "STREAM SIZE: "+streams.size.to_s
      streams.each do |stream|
        stream.windows.each do |window|
          data[group.name][:ip_incoming_size][stream.ip_incoming] += window.size_packets_incoming
          data[group.name][:ip_incoming_num][stream.ip_incoming] += window.num_packets_incoming
          data[group.name][:ip_outgoing_size][stream.ip_outgoing] += window.size_packets_outgoing
          data[group.name][:ip_outgoing_num][stream.ip_outgoing] += window.num_packets_outgoing
          
          data[group.name][:ip_all_size][stream.ip_incoming] += window.data(:incoming, :kilobyte)
          data[group.name][:ip_all_size][stream.ip_outgoing] += window.data(:outgoing, :kilobyte)
            
          data[group.name][:port_incoming_size][stream.port_incoming] += window.size_packets_incoming
          data[group.name][:port_incoming_num][stream.port_incoming] += window.num_packets_incoming
          data[group.name][:port_outgoing_size][stream.port_outgoing] += window.size_packets_outgoing
          data[group.name][:port_outgoing_num][stream.port_outgoing] += window.num_packets_outgoing
          
          data[group.name][:all_size] += window.size_packets_all
          data[group.name][:all_num] += window.num_packets_all
        end
      end
    end
    data
  end
  
end
