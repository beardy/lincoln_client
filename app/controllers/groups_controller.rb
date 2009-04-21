class GroupsController < ApplicationController
  
  def index
    # initialize user-selected groups
    selected_groups = Group.find(@selected_groups)
    
    # define all index page graphs
    @timeline_graphs = [
      BeardGraph::TimelineGraphAllGroupsDataSize.new("Data Size", @time_range, {:width => 500, :height => 330}),
      BeardGraph::TimelineGraphAllGroupsDataSizeNormalized.new("Normalized Data Size", @time_range, {:width => 500, :height => 330}), 
      BeardGraph::TimelineGraphAllGroupsPacketCount.new("Packet Count", @time_range, {:width => 500, :height => 330}),
      BeardGraph::TimelineGraphAllGroupsPacketCountNormalized.new("Normalized Packet Count", @time_range, {:width => 500, :height => 330})
    ]
    
    @daily_graphs = [
      BeardGraph::TopGraphAllGroupsDailyTraffic.new("Daily Traffic", @time_range)
    ]
    
    @group_graphs = [
      BeardGraph::TopGraphAllGroupsGroups.new("Group Distributions")
    ]
    
    @ip_graphs = [
      BeardGraph::TopGraphAllGroupsIPAddresses.new("Top IP Addresses")
    ]

    # initialize all graph data
    generate_graph_data(selected_groups, @timeline_graphs + @daily_graphs + @group_graphs + @ip_graphs)
  end
  
  def show
    # initialize user-selected groups
    selected_groups = Group.find(params[:id]).to_a
	@group = selected_groups.first
    
    # define all group details page graphs
    @timeline_graphs = [
      BeardGraph::TimelineGraphGroupDetailsDataSize.new("Data Size", @time_range, {:width => 500, :height => 330}),
      BeardGraph::TimelineGraphGroupDetailsDataSizeNormalized.new("Normalized Data Size", @time_range, {:width => 500, :height => 330}), 
      BeardGraph::TimelineGraphGroupDetailsPacketCount.new("Packet Count", @time_range, {:width => 500, :height => 330}),
      BeardGraph::TimelineGraphGroupDetailsPacketCountNormalized.new("Normalized Packet Count", @time_range, {:width => 500, :height => 330})
    ]
    
    @daily_graphs = [
      BeardGraph::TopGraphGroupDetailsDailyTraffic.new("Daily Traffic", @time_range)
    ]
    
    @port_graphs = [
      BeardGraph::TopGraphGroupDetailsPortsIncoming.new("Top Incoming Ports"), 
      BeardGraph::TopGraphGroupDetailsPortsOutgoing.new("Top Outgoing Ports")
    ]
    
    @ip_graphs = [
      BeardGraph::TopGraphGroupDetailsIPAddresses.new("Top IP Addresses")
    ]

    # initialize all graph data
    generate_graph_data(selected_groups, @timeline_graphs + @daily_graphs + @port_graphs + @ip_graphs)
  end
  
  def generate_graph_data(groups, graphs)
    # perform data aggregation pre-processing for each graph 
    graphs.map { |graph| graph.preprocess(groups) }

    # for each group, aggregate data for each graph
    groups.to_a.each do |group|
      # retreive all streams for this group
      @streams = Stream.relevant_streams(@time_range, group, @global_rule)
      @streams.each do |stream|
        stream.windows.each do |window|
          # perform graph-specific data aggregation
          graphs.map { |graph| graph.process(group, window) } 
        end
      end
    end

    # perform data aggregation post-processing for each graph 
    graphs.map { |graph| graph.postprocess(groups) }

    # generate all Open Flash Chart graphs
    graphs.map { |graph| graph.generate_graph }
  end
  
end
