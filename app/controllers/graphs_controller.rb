class GraphsController < ApplicationController
  GRAPH_HOOKS = %w(preprocess process postprocess generate_graph)
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
    
  end
  
  def aggregate_data(groups)
    data = {}
    groups.to_a.each do |group|
      data[group] = Hash.new(Hash.new)
      streams = Stream.relevant_streams(@time_range, group, @global_rule)
      streams.each do |stream|
        stream.windows.each do |window|
          data[group][:ip_incoming_size][stream.ip_incoming] = window.size_packets_incoming
        end
      end
    end
  end
  
  # graph_groups is an array of arrays of our shell graphs
  def generate_detail_graphs(graph_groups)
    # generate data
    data = nil
    
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
          graph.call(hook)
        end
      end
    end
    graph_groups
  end
  
end
