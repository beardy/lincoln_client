require 'graph_builder'
class GroupsController < ApplicationController
  
  
  # GET /gene_groups
  # GET /gene_groups.xml
  def index
    # @groups = Group.find(:all)
	
    # Here's the basic use of the starting_between named scope
    # =>  @streams = Stream.starting_between(@start_time, @end_time)
    # Here's how we can use it with the built in finds for more granularity
    #  so w're using the starting_between to scope the results, then the find
    #  to get a specific subset of that. Its beautiful!
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find_all_by_port_incoming(80)
    
    # TODO : so far we're not separating by groups. See notes in group and rule models 
    #  for my current ideas. Let me know what you think.
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /gene_groups/1
  # GET /gene_groups/1.xml
  def show
    @group = Group.find(params[:id])
    puts "rules: "+@group.to_sql
    rule_string = @group.to_sql
    puts "RULE : "+rule_string
    # @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find(:all, :conditions => rule_string)
    
    # @graph1 = GraphBuilder.build(:line, data_set, {options})
  	@graph1 = open_flash_chart_object(500,300,url_for(:action => "packet_size", :id => @group.id, :only_path => true))
  	@graph2 = open_flash_chart_object(500,300,url_for(:action => "packet_number", :id => @group.id, :only_path => true))

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end
  
  def packet_size
    @group = Group.find(params[:id])
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find(:all, :conditions => @group.to_sql)
    #
    # initialize data
    #
    data = {}
    data["Incoming"] = Array.new(@time_range.ticks, 0)
    data["Outgoing"] = Array.new(@time_range.ticks, 0)
    # inc_data = Array.new(@time_range.ticks, 0)
    # out_data = Array.new(@time_range.ticks, 0)

    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
        # for each tick
        @time_range.each_tick_with_time do |tick, tick_time|
          # if within tick range, add data
          if window.between?(tick_time)
            data["Incoming"][tick] += window.data(:incoming, :kilobyte) * @time_range.ratio
            data["Outgoing"][tick] += window.data(:outgoing, :kilobyte) * @time_range.ratio
          end
        end
      end
    end
    
    options = {:title => "Packet Size - Incoming vs. Outgoing",
               :legend => "Packet Data in KB"}
    builder = GraphBuilder.new(:line, data, options)
    chart = builder.build
    render :text => chart.render
  end
  
  def packet_number
    @group = Group.find(params[:id])
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find(:all, :conditions => @group.to_sql)
    data = {}
    data["Incoming"] = Array.new(@time_range.ticks, 0)
    data["Outgoing"] = Array.new(@time_range.ticks, 0)
    # inc_data = Array.new(@time_range.ticks, 0)
    # out_data = Array.new(@time_range.ticks, 0)

    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
        # for each tick
        @time_range.each_tick_with_time do |tick, tick_time|
          # if within tick range, add data
          if window.between?(tick_time)
            data["Incoming"][tick] += window.num_packets_incoming * @time_range.ratio
            data["Outgoing"][tick] += window.num_packets_outgoing * @time_range.ratio
          end
        end
      end
    end
    
    options = {:title => "Packet Count - Incoming vs. Outgoing",
               :legend => "Packet Count"}
    builder = GraphBuilder.new(:line, data, options)
    chart = builder.build
    render :text => chart.render
  end
    
  def update_time_range
    @time_range.update(params[:name], params[:date])
    # session[params[:name].to_sym] = Time.zone.parse(params["date"])
    render :layout => false
  end
  
end
