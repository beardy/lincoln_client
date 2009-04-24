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
	
	# initialize raw data
    @streams = Stream.relevant_streams(@time_range, @global_rule).paginate :page => params[:page], :order => 'windows.start_time ASC'
    
    respond_to do |format|
      format.html # index.html.erb
      format.js { # AJAX pagination
        render :update do |page|
          page.replace_html 'raw_traffic', :partial => 'streams/streams', :locals => {:streams => @streams}
      end
      }
      format.xml  { render :xml => @groups }
    end
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
	
	# initialize raw data
	@streams = Stream.relevant_streams(@time_range, @global_rule, @group).paginate :page => params[:page], :order => 'windows.start_time ASC'
	
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
      format.js { # AJAX pagination
        render :update do |page|
          page.replace_html 'raw_traffic', :partial => 'streams/streams', :locals => {:streams => @streams}
      end
      }
    end
  end
  
  
  def order_streams    
    sort = case params['sort']
      when "start_time"  then "windows.start_time ASC"
      when "start_time_reverse"  then "windows.start_time DESC"
      when "end_time" then "windows.end_time ASC"
      when "end_time_reverse" then "windows.end_time DESC"
      when "ip_incoming" then "streams.raw_ip_incoming ASC"
      when "ip_incoming_reverse" then "streams.raw_ip_incoming DESC"
      when "port_incoming" then "streams.port_incoming ASC"
      when "port_incoming_reverse" then "streams.port_incoming DESC"
      when "ip_outgoing" then "streams.raw_ip_outgoing ASC"
      when "ip_outgoing_reverse" then "streams.raw_ip_outgoing DESC"
      when "port_outgoing" then "streams.port_outgoing ASC"
      when "port_outgoing_reverse" then "streams.port_outgoing DESC"
    end
    
    groups = [@global_rule]    
    if params[:id]
      groups << Group.find(params[:id])
    end

    @streams = Stream.relevant_streams(@time_range,*groups).paginate :page => params[:page], :order => sort

    if request.post?
      render :partial => "streams/streams", :locals => {:streams => @streams}
    else
      render :update do |page|
        page.replace_html 'raw_traffic', :partial => 'streams/streams', :locals => {:streams => @streams}
      end
    end

  end
  
  def generate_graph_data(groups, graphs)
    # perform data aggregation pre-processing for each graph 
    graphs.map { |graph| graph.preprocess(groups) }

    # for each group, aggregate data for each graph
    groups.to_a.each do |group|
      # retreive all streams for this group
      streams = Stream.relevant_streams(@time_range, group, @global_rule)
      streams.each do |stream|
        stream.windows.each do |window|
          # perform graph-specific data aggregation
          graphs.map { |graph| graph.process(group, stream, window) } 
        end
      end
    end

    # perform data aggregation post-processing for each graph 
    graphs.map { |graph| graph.postprocess(groups) }

    # generate all Open Flash Chart graphs
    graphs.map { |graph| graph.generate_graph }
  end
  
end
