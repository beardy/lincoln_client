require 'graph_builder'
class GroupsController < ApplicationController
  
  before_filter :get_selected_groups
  
  ################################
  ## INDEX METHODS  ##############
  ################################

  # GET /gene_groups
  # GET /gene_groups.xml
  def index
    @graph_packet_size_all = open_flash_chart_object(500,300,url_for(:action => "all_timeline_packet_size", :id => :all,:only_path => true))
    @graph_packet_num_all = open_flash_chart_object(500,300,url_for(:action => "all_timeline_packet_count", :id => :all,:only_path => true))
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).paginate :page => params[:page], :order => 'windows.start_time ASC'
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end
  
  def all_timeline_packet_size
    # get data
    data = acquire_all_group_data(:size_packets_all)
    # configure graph
     options = {:title => "Packet Size", :legend => "Packet Data in KB"}
     builder = GraphBuilder.new(:line, data, options)
     chart = builder.build
     render :text => chart.render
  end
  
  def all_timeline_packet_count
    # get data
    data = acquire_all_group_data(:num_packets_all)
    # configure graph
     options = {:title => "Packet Number", :legend => "Packet Count"}
     builder = GraphBuilder.new(:line, data, options)
     chart = builder.build
     render :text => chart.render
  end
  
  # Helper method that will grab all 'values' from the selected groups
  #   and returns it as a hash, ready for our graph builder
  def acquire_all_group_data(*values)
    data = {}
    @selected_groups.each do |group_index|
      group = Group.find(group_index.to_i)
      data[group] = Array.new(@time_range.ticks, 0)
      streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find(:all, :conditions => group.to_sql)
      streams.each do |stream|
        stream.windows.each do |window|
          # for each tick
          @time_range.each_tick_with_time do |tick, tick_time|
            # if within tick range, add data
            if window.between?(tick_time)
              # data["Incoming"][tick] += window.data(:incoming, :kilobyte) * @time_range.ratio
              values.each do |value|
                data[group][tick] += window.send(value.to_sym)*@time_range.ratio
              end
            end
          end
        end
      end
    end
    data
  end
  
  def get_selected_groups
    @selected_groups = session[:selected_groups] ||= @groups.collect {|g| g.id}
  end
  
  def toggle_selected_group
    group_id = params[:group_id].to_i
    present = @selected_groups.delete(group_id)
    if(!present)
      @selected_groups << group_id
    end
    render :layout => false
  end
  
  ################################
  ## SHOW METHODS  ###############
  ################################
  

  # GET /gene_groups/1
  # GET /gene_groups/1.xml
  def show
    @group = Group.find(params[:id])
    puts "rules: "+@group.to_sql
    rule_string = @group.to_sql
    puts "RULE : "+rule_string
    
  	@graph_timeline_packet_size = open_flash_chart_object(500,300,url_for(:action => "timeline_packet_size", :id => @group.id, :only_path => true))
  	@graph_timeline_packet_count = open_flash_chart_object(500,300,url_for(:action => "timeline_packet_count", :id => @group.id, :only_path => true))
  	@graph_timeline_packet_size_normal = open_flash_chart_object(500,300,url_for(:action => "timeline_packet_size_normal", :id => @group.id, :only_path => true))
  	@graph_timeline_packet_count_normal = open_flash_chart_object(500,300,url_for(:action => "timeline_packet_count_normal", :id => @group.id, :only_path => true))
	
	@graph_max_ip_address_packet_size = open_flash_chart_object(500,300,url_for(:action => "max_ip_address_packet_size", :id => @group.id, :only_path => true))
	#@graph_max_ip_address_packet_count = open_flash_chart_object(500,300,url_for(:action => "max_ip_address_packet_count", :id => @group.id, :only_path => true))
	
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end
  
  #
  # Timeline of Packet Sizes
  #
  def timeline_packet_size
    @group = Group.find(params[:id])
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find(:all, :conditions => @group.to_sql)
	@time_range.ticks = 15
	
    # initialize data
    data = {}
    data["Incoming"] = Array.new(@time_range.ticks, 0)
    data["Outgoing"] = Array.new(@time_range.ticks, 0)
    
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
    
    # configure graph
    options = {:title => "Packet Size - Incoming vs. Outgoing", :legend => "Packet Data in KB"}
    builder = GraphBuilder.new(:line, data, options)
    chart = builder.build
    render :text => chart.render
  end
  
  #
  # Timeline of Packet Counts
  #
  def timeline_packet_count
    @group = Group.find(params[:id])
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find(:all, :conditions => @group.to_sql)
	@time_range.ticks = 15
	
    # initialize data
    data = {}
    data["Incoming"] = Array.new(@time_range.ticks, 0)
    data["Outgoing"] = Array.new(@time_range.ticks, 0)

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
    
    # configure graph
    options = {:title => "Packet Count - Incoming vs. Outgoing", :legend => "Packet Count"}
    builder = GraphBuilder.new(:line, data, options)
    chart = builder.build
    render :text => chart.render
  end

  #
  # Normalized Timeline of Packet Sizes
  #
  def timeline_packet_size_normal
    @group = Group.find(params[:id])
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find(:all, :conditions => @group.to_sql)
    @time_range.ticks = 15
	
    # initialize data
    data = {}
    data["Incoming"] = Array.new(@time_range.ticks, 0)
    data["Outgoing"] = Array.new(@time_range.ticks, 0)

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

	# normalize data
	sum = data["Incoming"].zip(data["Outgoing"]).map{|x, y| x + y}
	data["Incoming"] = data["Incoming"].zip(sum).map{|x, y| if y == 0 then 0  else  x / y end }
	data["Outgoing"] = data["Outgoing"].zip(sum).map{|x, y| if y == 0  then 0 else  x / y  end }
	data["Incoming"] = data["Incoming"].zip(data["Outgoing"]).map{|x, y| x + y}
    
    # configure graph
    options = {:title => "Packet Count - Incoming vs. Outgoing", :legend => "Packet Count"}
    builder = GraphBuilder.new(:line, data, options)
    chart = builder.build
    render :text => chart.render
	
    #line_inc = AreaHollow.new
	#line_inc.fill = '#d01f3c'
	#line_inc.fill_alpha = 1
	#line_inc.values = inc_data.zip(inc_data2).map{|x, y| tmp = DotValue.new(y, "#d01f3c"); tmp.tooltip = "#{(x * 100).round}%"; tmp; }
    
    #line_out = AreaHollow.new
	#line_out.fill = '#356aa0'
	#line_out.fill_alpha = 1
	#line_out.values = out_data.map{|x| tmp = DotValue.new(x, "#356aa0"); tmp.tooltip = "#{(x * 100).round}%"; tmp; }
  end

  def timeline_packet_count_normal
    @group = Group.find(params[:id])
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find(:all, :conditions => @group.to_sql)
	@time_range.ticks = 15
	
    # initialize data
    data = {}
    data["Incoming"] = Array.new(@time_range.ticks, 0)
    data["Outgoing"] = Array.new(@time_range.ticks, 0)

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

	# normalize data
	sum = data["Incoming"].zip(data["Outgoing"]).map{|x, y| x + y}
	data["Incoming"] = data["Incoming"].zip(sum).map{|x, y| if y == 0 then 0  else  x / y end }
	data["Outgoing"] = data["Outgoing"].zip(sum).map{|x, y| if y == 0  then 0 else  x / y  end }
	data["Incoming"] = data["Incoming"].zip(data["Outgoing"]).map{|x, y| x + y}
    
    # configure graph
    options = {:title => "Packet Count - Incoming vs. Outgoing", :legend => "Packet Count"}
    builder = GraphBuilder.new(:line, data, options)
    chart = builder.build
    render :text => chart.render
	
    #line_inc = AreaHollow.new
	#line_inc.fill = '#d01f3c'
	#line_inc.fill_alpha = 1
	#line_inc.values = inc_data.zip(inc_data2).map{|x, y| tmp = DotValue.new(y, "#d01f3c"); tmp.tooltip = "#{(x * 100).round}%"; tmp; }
    
    #line_out = AreaHollow.new
	#line_out.fill = '#356aa0'
	#line_out.fill_alpha = 1
	#line_out.values = out_data.map{|x| tmp = DotValue.new(x, "#356aa0"); tmp.tooltip = "#{(x * 100).round}%"; tmp; }
  end

  def max_ip_address_packet_size
    @group = Group.find(params[:id])
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find(:all, :conditions => @group.to_sql)
	
	@time_range.ticks = 8
	top_count = 4
	
    #
    # initialize data
    #
	inc_data = Array.new(@time_range.ticks)
	out_data = Array.new(@time_range.ticks)
	
	@time_range.ticks.times do |i|
	  inc_data[i] = Hash.new(0)
	  out_data[i] = Hash.new(0)
	end

    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
      
        # for each tick
        @time_range.each_tick_with_time do |tick, tick_time|
          # if within tick range, add data
          if window.start_time <= tick_time and window.end_time >= tick_time
			inc_data[tick][stream.ip_incoming] += window.size_packets_incoming * @time_range.ratio
			out_data[tick][stream.ip_outgoing] += window.size_packets_outgoing * @time_range.ratio
          end
        end

      end
    end
	
    #
    # initialize graph
    #
    chart = OpenFlashChart.new
    chart.title = Title.new("Top IP Address - Incoming vs. Outgoing")
    
	y_max = 10
	
	# initialize top incoming bars
	top_count.times do |i|
	  bar = Bar.new
	  
	  if i == 0
	    bar.colour = "#d01f3c"
	    bar.text = "incoming"
	  end
	  
      # for each tick
      @time_range.each_tick_with_time do |tick, tick_time|
		# find max incoming (by value)
		max = inc_data[tick].max{|a,b| a[1] <=> b[1]}
		bar_value = BarValue.new(0)
		bar_value.tooltip = "0"

		unless max.nil? or max.last == 0
		  y_max = [y_max, max.last].max
		  inc_data[tick][max.first] = 0
		  
		  bar_value.top = max.last
          bar_value.colour = "#d01f3c"
          bar_value.tooltip = "#{max.first}<br>#val#"	
		end
		
		# add to bar
		bar.append_value(bar_value)
	  end
	  
	  # add to chart
	  chart.add_element(bar)
    end

	# initialize top outgoing bars
	top_count.times do |i|
	  bar = Bar.new

	  if i == 0
	    bar.colour = "#356aa0"
	    bar.text = "outgoing"
	  end
	  
      # for each tick
      @time_range.each_tick_with_time do |tick, tick_time|
		# find max outgoing
		max = out_data[tick].max{|a,b| a[1] <=> b[1]}
		bar_value = BarValue.new(0)
		bar_value.tooltip = "0"
		
		unless max.nil? or max.last == 0
		  y_max = [y_max, max.last].max
		  out_data[tick][max.first] = 0
		  
		  bar_value.top = max.last
          bar_value.colour = "#356aa0"
          bar_value.tooltip = "#{max.first}<br>#val#"
		end
		
		# add to bar
		bar.append_value(bar_value)
	  end
	  
	  # add to chart
	  chart.add_element(bar)
    end
	
	# initialize palette
    t = Tooltip.new
    t.shadow = false
    t.stroke = 5
    t.colour = "#6E604F"
    t.background_colour = "#BDB396"
    t.title_style = "{font-size: 14px; color: #CC2A43;}"
    t.body_style = "{font-size: 10px; font-weight: bold; color: #000000;}"
    chart.tooltip = t

    # initialize axis
    y = YAxis.new
    y.set_range(0, y_max, y_max / 10)
    chart.y_axis = y

    render :text => chart.to_s
  end

  def daily_traffic
    @group = Group.find(params[:id])
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find(:all, :conditions => @group.to_sql)
	
	#days_range = (@time_range.end_time - @time_range.start_time / 86400).round
	#@time_range.ticks = 15
	
    #
    # initialize data
    #
    inc_data = Array.new(@time_range.ticks, 0)
    out_data = Array.new(@time_range.ticks, 0)

    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
      
        # for each tick
        @time_range.each_tick_with_time do |tick,tick_time|
    
          # if within tick range, add data
          if window.start_time <= tick_time and window.end_time >= tick_time
            inc_data[tick] += window.num_packets_incoming * @time_range.ratio
            out_data[tick] += window.num_packets_outgoing * @time_range.ratio
          end
        end

      end
    end
    
	#out_data = out_data.zip(inc_data).map{|x, y| x + y} # convert to stacked line graph
	
    #
    # initialize graph
    #
    title = Title.new("Packet Count - Incoming vs. Outgoing")
    
    line_inc = LineDot.new
    line_inc.text = "Incoming"
    line_inc.width = 2
    line_inc.colour = '#d01f3c'
    line_inc.dot_size = 5
    line_inc.values = inc_data
    
    line_out = LineDot.new
    line_out.text = "Outgoing"
    line_out.width = 2
    line_out.colour = '#356aa0'
    line_out.dot_size = 5
    line_out.values = out_data

    #tmp = []
    #x_labels = XAxisLabels.new
    #x_labels.set_vertical()

    #%w(one two three four five six seven eight nine ten).each do |text|
    #  tmp << XAxisLabel.new(text, '#0000ff', 20, 'diagonal')
    #end

    #x_labels.labels = tmp

    #x = XAxis.new
    #x.set_labels(x_labels)

    y = YAxis.new
    max = [inc_data.max, out_data.max].max
    y.set_range(0, max, max / 10)

    #x_legend = XLegend.new("My X Legend")
    #x_legend.set_style('{font-size: 20px; color: #778877}')

    y_legend = YLegend.new("Packet Count")
    y_legend.set_style('{font-size: 20px; color: #770077}')


    chart = OpenFlashChart.new
    chart.set_title(title)
    #chart.set_x_legend(x_legend)
    chart.set_y_legend(y_legend)
    #chart.x_axis = x
    chart.y_axis = y

    chart.add_element(line_inc)
    chart.add_element(line_out)







   chart = OpenFlashChart.new

    title = Title.new("Scatter points")
    chart.set_title(title)

    scatter = Scatter.new('#FFD800', 10)  # color, dot size

    scatter.values = [
      ScatterValue.new(50,30),
      ScatterValue.new(305,400),
      ScatterValue.new(61,500,15),  # x, y, dot size
      ScatterValue.new(600,550),
      ScatterValue.new(459,300),
      ScatterValue.new(180,789)
    ]

    chart.add_element(scatter)

    x = XAxis.new
    x.set_range(0, 650, 100)  #min, max, steps
    # alternatively, you can use x.set_range(0,65000) and x.set_step(10000)
    x.colour = '#00FF00'
    # have to set the x axis labels because of scatter bug here - http://sourceforge.net/forum/message.php?msg_id=4812326
    x.set_grid_colour('#00F0FF')
    chart.set_x_axis(x)

    y = YAxis.new
    y.set_range(0,800,200)
    y.colour = '#FF0000'
    y.set_grid_colour('#FF00FF')
    chart.set_y_axis(y)

    render :text => chart.to_s

  end


  def update_time_range
    @time_range.update(params[:name], params[:date])
    # session[params[:name].to_sym] = Time.zone.parse(params["date"])
    render :layout => false
  end
end
