class GraphsController < ApplicationController
  
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
  
  # graph_instances is an array of our graph types
  def generate_detail_graphs(graph_instances)
    
  end
  
end
