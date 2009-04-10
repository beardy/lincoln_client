class GroupsController < ApplicationController
  
  before_filter :get_selected_groups
  
  ################################
  ## INDEX METHODS  ##############
  ################################

  # GET /gene_groups
  # GET /gene_groups.xml
  def index
    @graph_all_timeline_by_data_size = open_flash_chart_object(500, 300, url_for(:action => "all_timeline_by_data_size", :id => :all, :only_path => true))
    @graph_all_timeline_by_data_size_normal = open_flash_chart_object(500, 300, url_for(:action => "all_timeline_by_data_size_normal", :id => :all, :only_path => true))
    @graph_all_timeline_by_packet_count = open_flash_chart_object(500, 300, url_for(:action => "all_timeline_by_packet_count", :id => :all, :only_path => true))
    @graph_all_timeline_by_packet_count_normal = open_flash_chart_object(500, 300, url_for(:action => "all_timeline_by_packet_count_normal", :id => :all, :only_path => true))

    @graph_all_by_data_size = open_flash_chart_object(250, 200, url_for(:action => "all_by_data_size", :id => :all, :only_path => true))
    @graph_all_top_daily_by_data_size = open_flash_chart_object(250, 200, url_for(:action => "all_top_daily_by_data_size", :id => :all, :only_path => true))
	@graph_all_top_ip_by_data_size = open_flash_chart_object(250, 200, url_for(:action => "all_top_ip_by_data_size", :id => :all, :only_path => true))
    
    @streams = Stream.relevant_streams(@time_range, @global_rule).paginate :page => params[:page], :order => 'windows.start_time ASC'
    
    respond_to do |format|
      format.html # index.html.erb
      format.js { # AJAX pagination
        render :update do |page|
          page.replace_html 'raw_traffic', :partial => 'streams/streams'
      end
      }
      format.xml  { render :xml => @groups }
    end
  end
  
  #
  # Timeline of Network Traffic by Data Sizes (All Groups)
  #
  def all_timeline_by_data_size
    # get data
    data = acquire_all_group_data(:size_packets_all)
	
	# find max data value
	max = data.inject(0) { |max, n| [max, n[1][:values].max].max }

	# scale data
	scale = 1
	labels = %w[B KB MB GB TB PB EB]
	label = labels[0]
	labels.each { |n| if max / (scale * 1024) > 1 then scale *= 1024; label = n; else break end }
	
	# update values
	data.each_value { |v| 
	 v[:values].map! { |n| n / scale }
	 v[:keys] = v[:values].map { |n| sprintf("%6.6f #{label}", n) }
	}
	
    # configure graph
    options = {:title => "Group Data Sizes (in #{label})", :x_axis_label_format => "%4.4f"}
    builder = GraphBuilder.new(:line, data, options)
    chart = builder.build
    render :text => chart.render
  end
  
  #
  # Timeline of Network Traffic by Packet Counts (All Groups)
  #
  def all_timeline_by_packet_count
    # get data
    data = acquire_all_group_data(:num_packets_all)
	
    # configure graph
	options = {:title => "Group Packet Counts"}
    builder = GraphBuilder.new(:line, data, options)
    chart = builder.build
    render :text => chart.render
  end

  #
  # Timeline of Network Traffic by Normalized Data Sizes (All Groups)
  #
  def all_timeline_by_data_size_normal
    # get data
    data = acquire_all_group_data(:size_packets_all)
	
	# normalize data values
	unless data.empty?
	  sum = data.inject(Array.new(@time_range.ticks, 0)){|sum, n| sum.zip(n[1][:values]).map{|x, y| x + y}}
	  data.each_key{|key| 
	    # normalize data values
	    data[key][:values] = data[key][:values].zip(sum).map{|x, y| if y == 0 then 0  else  x / y end }
		# initialize data text
		data[key][:keys] = data[key][:values].map{|x| "#{(x * 100).round}%"}
	  }
	  
	  # sum normalized data
	  data.to_a.reverse.inject(Array.new(@time_range.ticks, 0)){|sum, n|
	    tmp = sum.zip(n[1][:values]).map{|x, y| x + y}
		data[n[0]][:values] = tmp
		tmp
	  }
	end
    
    # configure graph
    options = {:title => "Group Data Sizes (in %)"}
    builder = GraphBuilder.new(:area, data, options)
    chart = builder.build
    render :text => chart.render
  end

  #
  # Timeline of Network Traffic by Normalized Packet Counts (All Groups)
  #
  def all_timeline_by_packet_count_normal
    # get data
    data = acquire_all_group_data(:num_packets_all)
	
	# normalize data values
	unless data.empty?
	  sum = data.inject(Array.new(@time_range.ticks, 0)){|sum, n| sum.zip(n[1][:values]).map{|x, y| x + y}}
	  data.each_key{|key| 
	    # normalize data values
	    data[key][:values] = data[key][:values].zip(sum).map{|x, y| if y == 0 then 0  else  x / y end }
		# initialize data text
		data[key][:keys] = data[key][:values].map{|x| "#{(x * 100).round}%"}
	  }
	  
	  # sum normalized data
	  data.to_a.reverse.inject(Array.new(@time_range.ticks, 0)){|sum, n|
	    tmp = sum.zip(n[1][:values]).map{|x, y| x + y}
		data[n[0]][:values] = tmp
		tmp
	  }
	end
    
    # configure graph
    options = {:title => "Group Packet Counts (in %)"}
    builder = GraphBuilder.new(:area, data, options)
    chart = builder.build
    render :text => chart.render
  end
  
  #
  # Distribution by Data Size (All Groups)
  #
  def all_by_data_size
    # get all data
    all_data = acquire_all_group_data(:size_packets_all)
	
	# sum data values
	data = {"All" => {}}
	unless all_data.empty?
	  data["All"][:values] = all_data.map{|n| n[1][:values].inject(0){|sum, x| sum + x}}
	  #data["All"][:keys] = data["All"][:values].map{"#val#"}
	  
	  all_sum = data["All"][:values].inject(0){|sum, x| sum + x}
	  data["All"][:x_labels] = all_data.zip(data["All"][:values]).map{|x, y| "#{x[0]} (#{if all_sum == 0 then 0 else (y * 100 / all_sum).round end}%)"}
    end

	# find max data value
	max = data.inject(0) { |max, n| [max, n[1][:values].max].max }

	# scale data
	scale = 1
	labels = %w[B KB MB GB TB PB EB]
	label = labels[0]
	labels.each { |n| if max / (scale * 1024) > 1 then scale *= 1024; label = n; else break end }
	
	# update values
	data.each_value { |v| 
	 v[:values].map! { |n| n / scale }
	 v[:keys] = v[:values].map { |n| sprintf("%6.6f #{label}", n) }
	}

    # configure graph
    options = {}#{:title => "Data Size", :legend => "Data Size (in KB)"}
    builder = GraphBuilder.new(:pie, data, options)
    chart = builder.build
    render :text => chart.render
  end

  #
  # Distribution of Top IP Addresses by Data Size (All Groups)
  #
  def all_top_ip_by_data_size
	top_count = 10
	
    # initialize all data
    all_data = {}
    @selected_groups.each do |group_index|
      group = Group.find(group_index.to_i)
	  all_data[group] = Hash.new(0)
      streams = Stream.relevant_streams(@time_range, group, @global_rule )
	  
      streams.each do |stream|
        stream.windows.each do |window|
          # sum packet size
		  all_data[group][stream.ip_incoming] += window.data(:incoming, :kilobyte)
		  all_data[group][stream.ip_outgoing] += window.data(:outgoing, :kilobyte)
        end
      end
    end
  
	# initialize top data values and text
    data = {}
    @selected_groups.each do |group_index|
	  group = Group.find(group_index.to_i)
      data[group] = {:values => Array.new(top_count, 0), :keys => Array.new(top_count, 0)}

	  top_count.times do |i|
	    # find max (by value)
	    max = all_data[group].max{|a,b| a[1] <=> b[1]}
	    unless max.nil? or max.last == 0
		  data[group][:values][i] = max.last
		  data[group][:keys][i] = "#{max.first}"#<br>#{max.last}"
		  all_data[group][max.first] = 0
	    end
      end
	end
	
	# find max data value
	max = data.inject(0) { |max, n| [max, n[1][:values].max].max }

	# scale data
	scale = 1
	labels = %w[B KB MB GB TB PB EB]
	label = labels[0]
	labels.each { |n| if max / (scale * 1024) > 1 then scale *= 1024; label = n; else break end }
	
	# update values
	data.each_value { |v| 
	 v[:values].map! { |n| n / scale }
	 v[:keys] = v[:keys].zip(v[:values]).map { |k, v| sprintf("#{k}<br>%6.6f #{label}", v) }
	}
	
    # configure graph
    options = {}#{:title => "Top Data Sizes (in #{label})", :x_axis_label_format => "%4.4f"}
    builder = GraphBuilder.new(:bar, data, options)
    chart = builder.build
    render :text => chart.render
  end

  #
  # Distribution of Daily Traffic by Data Size (All Groups)
  #
  def all_top_daily_by_data_size
	top_count = 10
	dot_size_max = 20
	dot_size_min = 5
	dot_size_range = dot_size_max - dot_size_min
	
	# initialize time information
	start_day = Time.parse(@time_range.start_time.strftime("%a %b %d 00:00:00 %Z %Y"))
	end_day = Time.parse(@time_range.end_time.strftime("%a %b %d 00:00:00 %Z %Y")) + 1.day
	days = ((end_day - start_day) / 1.day).round
	puts "DAYS: #{days}"
	start_hour = Time.parse(@time_range.start_time.strftime("%a %b %d %H:00:00 %Z %Y"))
	end_hour = Time.parse(@time_range.end_time.strftime("%a %b %d %H:00:00 %Z %Y")) + 1.hour
	hours = ((end_hour - start_hour) / 1.hour).round
	puts "HOURS: #{hours}"
	start_day_hour = @time_range.start_time.hour
	end_day_hour = @time_range.end_time.hour
	
    # initialize all data
    all_data = {}
    all_data["Data"] = Hash.new(0)
	
    @selected_groups.each do |group_index|
      group = Group.find(group_index.to_i)
      # streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).filtered_by(@global_rule).filtered_by(group)
      streams = Stream.relevant_streams(@time_range, group, @global_rule )
      puts "---------RESULT SIZE: "+streams.size.to_s+"---------------"
      streams.each do |stream|
        stream.windows.each do |window|

		  # find hour indexes
	      start_hour_index = ((Time.parse(window.start_time.strftime("%a %b %d %H:00:00 %Z %Y")) - start_hour) / 1.hour).round
	      end_hour_index = ((Time.parse(window.end_time.strftime("%a %b %d %H:00:00 %Z %Y")) - start_hour) / 1.hour).round
	      # sum data
	      if start_hour_index == end_hour_index
		    all_data["Data"][start_hour_index] += window.data(:all, :kilobyte)
		  else
		    start_ratio = (start_hour + end_hour_index - window.start_time) / @time_range.window
		    all_data["Data"][start_hour_index] += window.data(:all, :kilobyte) * start_ratio
		    if (end_hour_index < hours)
		      all_data["Data"][end_hour_index] += window.data(:all, :kilobyte) * (1 - start_ratio)
		    end
		  end

        end
      end
    end
	
	# initialize top data: values, text, and x-axis labels
    data = {}
    data["Data"] = {
	  :values => Array.new()
	}

    temp = Array.new()

	# find max data value
	all_max = all_data["Data"].max{|a,b| a[1] <=> b[1]}

	# scale data
	scale = 1
	labels = %w[B KB MB GB TB PB EB]
	label = labels[0]
	labels.each { |n| if all_max[1] / (scale * 1024) > 1 then scale *= 1024; label = n; else break end }
	
	top_count.times do |i|
	  # find max
	  max = all_data["Data"].max{|a,b| a[1] <=> b[1]}
	  unless max.nil? or max.last == 0
		y = (start_day_hour + max.first) % 24
		x = start_day_hour + max.first
		data["Data"][:values].push(ScatterValue.new(x,y))
		data["Data"][:values].last.tooltip = sprintf("%6.6f #{label}",  max.last / scale)
		temp.push(max.last)
		all_data["Data"][max.first] = 0
	  end
    end

    # update dot sizes
    value_range = temp.first - temp.last

    temp.each_with_index do |x, i|
	  data["Data"][:values][i].dot_size = ((temp[i] - temp.last) / value_range) * dot_size_range + dot_size_min
	end

    # initialize chart
    chart = OpenFlashChart.new

    #title = Title.new("Scatter points")
    #chart.set_title(title)

    scatter = Scatter.new('#1C6569', dot_size_min)  # color, dot size
    scatter.values = data["Data"][:values]
    chart.add_element(scatter)

    x = XAxis.new
    x.set_range(0, days * 24, 24)
    chart.set_x_axis(x)

    y = YAxis.new
    y.set_range(0,24,4)
    chart.set_y_axis(y)

    render :text => chart.to_s
  end
  
  # Helper method that will grab all 'values' from the selected groups
  #   and returns it as a hash, ready for our graph builder
  def acquire_all_group_data(*values)
    data = {}
    @selected_groups.each do |group_index|
      group = Group.find(group_index.to_i)
	  data[group] = {:values => Array.new(@time_range.ticks, 0)}
      # streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).filtered_by(@global_rule).filtered_by(group)
      streams = Stream.relevant_streams(@time_range, group, @global_rule )
      puts "---------RESULT SIZE: "+streams.size.to_s+"---------------"
      streams.each do |stream|
        stream.windows.each do |window|
          # for each tick
          @time_range.each_tick_with_time do |tick, tick_time|
            # if within tick range, add data
            if window.between?(tick_time)
              values.each do |value|
                data[group][:values][tick] += window.send(value.to_sym)*@time_range.ratio
              end
            end
          end
        end
      end
    end
    data
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
  ## SHOW METHODS  ##################
  ################################
  
  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])
	
  	@graph_timeline_by_data_size = open_flash_chart_object(500, 300, url_for(:action => "timeline_by_data_size", :id => @group.id, :only_path => true))
  	@graph_timeline_by_data_size_normal = open_flash_chart_object(500, 300, url_for(:action => "timeline_by_data_size_normal", :id => @group.id, :only_path => true))
	@graph_timeline_by_packet_count = open_flash_chart_object(500, 300, url_for(:action => "timeline_by_packet_count", :id => @group.id, :only_path => true))
  	@graph_timeline_by_packet_count_normal = open_flash_chart_object(500, 300, url_for(:action => "timeline_by_packet_count_normal", :id => @group.id, :only_path => true))
	
	@graph_top_daily_by_data_size = open_flash_chart_object(250, 200, url_for(:action => "top_daily_by_data_size", :id => @group.id, :only_path => true))
	@graph_top_inc_port_by_data_size = open_flash_chart_object(250, 200, url_for(:action => "top_inc_port_by_data_size", :id => @group.id, :only_path => true))
	@graph_top_out_port_by_data_size = open_flash_chart_object(250, 200, url_for(:action => "top_out_port_by_data_size", :id => @group.id, :only_path => true))
	@graph_top_ip_by_data_size = open_flash_chart_object(250, 200, url_for(:action => "top_ip_by_data_size", :id => @group.id, :only_path => true))
	@streams = Stream.relevant_streams(@time_range, @global_rule, @group).paginate :page => params[:page], :order => 'windows.start_time ASC'
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
      format.js { # AJAX pagination
        render :update do |page|
          page.replace_html 'raw_traffic', :partial => 'streams/streams'
      end
      }
    end
  end
  
  #
  # Timeline of Network Traffic by Data Sizes
  #
  def timeline_by_data_size
    @group = Group.find(params[:id])
    @streams = Stream.relevant_streams(@time_range,  @group, @global_rule)

    # initialize data
    data = {}
    data["Incoming"] = {:values => Array.new(@time_range.ticks, 0)}
    data["Outgoing"] = {:values => Array.new(@time_range.ticks, 0)}
    
    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
        # for each tick
        @time_range.each_tick_with_time do |tick, tick_time|
          # if within tick range, add data
          if window.between?(tick_time)
            data["Incoming"][:values][tick] += window.data(:incoming, :kilobyte) * @time_range.ratio
            data["Outgoing"][:values][tick] += window.data(:outgoing, :kilobyte) * @time_range.ratio
          end
        end
      end
    end
    
	# find max data value
	max = data.inject(0) { |max, n| [max, n[1][:values].max].max }

	# scale data
	scale = 1
	labels = %w[B KB MB GB TB PB EB]
	label = labels[0]
	labels.each { |n| if max / (scale * 1024) > 1 then scale *= 1024; label = n; else break end }
	
	# update values
	data.each_value { |v| 
	 v[:values].map! { |n| n / scale }
	 v[:keys] = v[:values].map { |n| sprintf("%6.6f #{label}", n) }
	}
	
    # configure graph
    options = {:title => "Incoming vs Outgoing Data Sizes (in #{label})"}
    builder = GraphBuilder.new(:line, data, options)
    chart = builder.build
    render :text => chart.render
  end
  
  #
  # Timeline of Network Traffic by Packet Counts
  #
  def timeline_by_packet_count
    @group = Group.find(params[:id])
    @streams = Stream.relevant_streams(@time_range, @group, @global_rule)

    # initialize data
    data = {}
    data["Incoming"] = {:values => Array.new(@time_range.ticks, 0)}
    data["Outgoing"] = {:values => Array.new(@time_range.ticks, 0)}

    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
        # for each tick
        @time_range.each_tick_with_time do |tick, tick_time|
          # if within tick range, add data
          if window.between?(tick_time)
            data["Incoming"][:values][tick] += window.num_packets_incoming * @time_range.ratio
            data["Outgoing"][:values][tick] += window.num_packets_outgoing * @time_range.ratio
          end
        end
      end
    end
    
    # configure graph
    options = {:title => "Incoming vs Outgoing Packet Counts"}
    builder = GraphBuilder.new(:line, data, options)
    chart = builder.build
    render :text => chart.render
  end

  #
  # Timeline of Network Traffic by Normalized Data Sizes
  #
  def timeline_by_data_size_normal
    @group = Group.find(params[:id])
    @streams = Stream.relevant_streams(@time_range, @group, @global_rule)

    # initialize data values
    data = {}
    data["Incoming"] = {:values => Array.new(@time_range.ticks, 0)}
    data["Outgoing"] = {:values => Array.new(@time_range.ticks, 0)}

    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
        # for each tick
        @time_range.each_tick_with_time do |tick, tick_time|
          # if within tick range, add data
          if window.between?(tick_time)
            data["Incoming"][:values][tick] += window.data(:incoming, :kilobyte) * @time_range.ratio
            data["Outgoing"][:values][tick] += window.data(:outgoing, :kilobyte) * @time_range.ratio
          end
        end
      end
    end

	# normalize data values
	sum = data["Incoming"][:values].zip(data["Outgoing"][:values]).map{|x, y| x + y}
	data["Incoming"][:values] = data["Incoming"][:values].zip(sum).map{|x, y| if y == 0 then 0  else  x / y end }
	data["Outgoing"][:values] = data["Outgoing"][:values].zip(sum).map{|x, y| if y == 0  then 0 else  x / y  end }
	
	# initialize data text
	data["Incoming"][:keys] = data["Incoming"][:values].map{|x| "#{(x * 100).round}%"}
	data["Outgoing"][:keys] = data["Outgoing"][:values].map{|x| "#{(x * 100).round}%"}
	
	# sum normalized data
	data["Outgoing"][:values] = data["Outgoing"][:values].zip(data["Incoming"][:values]).map{|x, y| x + y}
    
    # configure graph
    options = {:title => "Incoming vs Outgoing Data Size (in %): "}
    builder = GraphBuilder.new(:area, data, options)
    chart = builder.build
    render :text => chart.render
  end

  #
  # Timeline of Network Traffic by Normalized Packet Counts
  #
  def timeline_by_packet_count_normal
    @group = Group.find(params[:id])
    @streams = Stream.relevant_streams(@time_range, @group, @global_rule)

    # initialize data
    data = {}
    data["Incoming"] = {:values => Array.new(@time_range.ticks, 0)}
    data["Outgoing"] = {:values => Array.new(@time_range.ticks, 0)}

    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
        # for each tick
        @time_range.each_tick_with_time do |tick, tick_time|
          # if within tick range, add data
          if window.between?(tick_time)
            data["Incoming"][:values][tick] += window.num_packets_incoming * @time_range.ratio
            data["Outgoing"][:values][tick] += window.num_packets_outgoing * @time_range.ratio
          end
        end
      end
    end

	# normalize data values
	sum = data["Incoming"][:values].zip(data["Outgoing"][:values]).map{|x, y| x + y}
	data["Incoming"][:values] = data["Incoming"][:values].zip(sum).map{|x, y| if y == 0 then 0  else  x / y end }
	data["Outgoing"][:values] = data["Outgoing"][:values].zip(sum).map{|x, y| if y == 0  then 0 else  x / y  end }
	
	# initialize data text
	data["Incoming"][:keys] = data["Incoming"][:values].map{|x| "#{(x * 100).round}%"}
	data["Outgoing"][:keys] = data["Outgoing"][:values].map{|x| "#{(x * 100).round}%"}
	
	# sum normalized data
	data["Outgoing"][:values] = data["Outgoing"][:values].zip(data["Incoming"][:values]).map{|x, y| x + y}
    
    # configure graph
    options = {:title => "Incoming vs Outgoing Packet Counts (in %)"}
    builder = GraphBuilder.new(:area, data, options)
    chart = builder.build
    render :text => chart.render
  end

  #
  # Distribution of Top IP Addresses by Data Size
  #
  def top_ip_by_data_size
    @group = Group.find(params[:id])
    @streams = Stream.relevant_streams(@time_range, @group, @global_rule)
	
	top_count = 10
	
    # initialize all data
    all_data = {}
    all_data["Incoming"] = Hash.new(0)
    all_data["Outgoing"] = Hash.new(0)

    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
        # sum packet size
		all_data["Incoming"][stream.ip_incoming] += window.data(:incoming, :kilobyte) * @time_range.ratio
		all_data["Outgoing"][stream.ip_outgoing] += window.data(:outgoing, :kilobyte) * @time_range.ratio
      end
    end
	
	# initialize top data values and text
    data = {}
    data["Incoming"] = {:values => Array.new(top_count, 0), :keys => Array.new(top_count, 0)}
    data["Outgoing"] = {:values => Array.new(top_count, 0), :keys => Array.new(top_count, 0)}

	top_count.times do |i|
	  # find max incoming (by value)
	  max = all_data["Incoming"].max{|a,b| a[1] <=> b[1]}
	  unless max.nil? or max.last == 0
		data["Incoming"][:values][i] = max.last
		data["Incoming"][:keys][i] = "#{max.first}"#<br>#{max.last}"
		all_data["Incoming"][max.first] = 0
	  end
		
	  # find max outgoing (by value)
	  max = all_data["Outgoing"].max{|a,b| a[1] <=> b[1]}
	  unless max.nil? or max.last == 0
		data["Outgoing"][:values][i] = max.last
		data["Outgoing"][:keys][i] = "#{max.first}"#<br>#val#"
		all_data["Outgoing"][max.first] = 0
	  end
    end

	# find max data value
	max = data.inject(0) { |max, n| [max, n[1][:values].max].max }

	# scale data
	scale = 1
	labels = %w[B KB MB GB TB PB EB]
	label = labels[0]
	labels.each { |n| if max / (scale * 1024) > 1 then scale *= 1024; label = n; else break end }
	
	# update values
	data.each_value { |v| 
	 v[:values].map! { |n| n / scale }
	 v[:keys] = v[:keys].zip(v[:values]).map { |k, v| sprintf("#{k}<br>%6.6f #{label}", v) }
	}
	
    # configure graph
    options = {}#{:title => "Top IP Address: Incoming vs Outgoing", :legend => "Data Size (in KB)"}
    builder = GraphBuilder.new(:bar, data, options)
    chart = builder.build
    render :text => chart.render
  end

  #
  # Distribution of Top Incoming Ports by Data Size
  #
  def top_inc_port_by_data_size
    @group = Group.find(params[:id])
    @streams = Stream.relevant_streams(@time_range, @group, @global_rule)
	
	top_count = 5
	
    # initialize all data
    all_data = {}
    all_data["Incoming"] = Hash.new(0)

    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
        # sum packet size
		all_data["Incoming"][stream.port_incoming] += window.size_packets_incoming
      end
    end
	
	all_sum = all_data["Incoming"].inject(0){|sum,n| sum + n[1]}
	
	# initialize top data: values, text, and x-axis labels
    data = {}
    data["Incoming"] = {
	  :values => Array.new(), 
	  :keys => Array.new(),
	  :x_labels => Array.new()
	}

	top_count.times do |i|
	  # find max incoming (by value)
	  max = all_data["Incoming"].max{|a,b| a[1] <=> b[1]}
	  unless max.nil? or max.last == 0
		data["Incoming"][:values].push(max.last)
		#data["Incoming"][:keys].push("#val#")
		data["Incoming"][:x_labels].push("#{max.first} (#{if all_sum == 0 then 0 else (max.last * 100 / all_sum).round end}%)")
		all_data["Incoming"][max.first] = 0
	  end
    end

    other_sum = all_data["Incoming"].inject(0){|sum,n| sum + n[1]}
	data["Incoming"][:values].push(other_sum)
	#data["Incoming"][:keys].push("#val#")
	data["Incoming"][:x_labels].push("Other (#{if all_sum == 0 then 0 else (other_sum * 100 / all_sum).round end}%)")
	
	# find max data value
	max = data.inject(0) { |max, n| [max, n[1][:values].max].max }

	# scale data
	scale = 1
	labels = %w[B KB MB GB TB PB EB]
	label = labels[0]
	labels.each { |n| if max / (scale * 1024) > 1 then scale *= 1024; label = n; else break end }
	
	# update values
	data.each_value { |v| 
	 v[:values].map! { |n| n / scale }
	 v[:keys] = v[:values].map { |n| sprintf("%6.6f #{label}", n) }
	}

    # configure graph
    options = {}#{:title => "Top Incoming Ports", :legend => "Data Size (in KB)"}
    builder = GraphBuilder.new(:pie, data, options)
    chart = builder.build
    render :text => chart.render
  end

  #
  # Distribution of Top Outgoing Ports by Data Size
  #
  def top_out_port_by_data_size
    @group = Group.find(params[:id])
    @streams = Stream.relevant_streams(@time_range, @group, @global_rule)
	
	top_count = 5
	
    # initialize all data
    all_data = {}
    all_data["Outgoing"] = Hash.new(0)

    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
        # sum packet size
		all_data["Outgoing"][stream.port_outgoing] += window.size_packets_outgoing
      end
    end
	
	all_sum = all_data["Outgoing"].inject(0){|sum,n| sum + n[1]}
	puts "SUM: #{all_sum}"
	
	# initialize top data values and text
    data = {}
    data["Outgoing"] = {
	  :values => Array.new(), 
	  :keys => Array.new(),
	  :x_labels => Array.new()
	}

	top_count.times do |i|
	  # find max outgoing (by value)
	  max = all_data["Outgoing"].max{|a,b| a[1] <=> b[1]}
	  unless max.nil? or max.last == 0
		data["Outgoing"][:values].push(max.last)
		#data["Outgoing"][:keys].push("#val#")
		data["Outgoing"][:x_labels].push("#{max.first} (#{if all_sum == 0 then 0 else (max.last * 100 / all_sum).round end}%)")
		all_data["Outgoing"][max.first] = 0
	  end
    end

    other_sum = all_data["Outgoing"].inject(0){|sum,n| sum + n[1]}
	data["Outgoing"][:values].push(other_sum)
	#data["Outgoing"][:keys].push("#val#")
	data["Outgoing"][:x_labels].push("Other (#{if all_sum == 0 then 0 else (other_sum * 100 / all_sum).round end}%)")
	
	# find max data value
	max = data.inject(0) { |max, n| [max, n[1][:values].max].max }

	# scale data
	scale = 1
	labels = %w[B KB MB GB TB PB EB]
	label = labels[0]
	labels.each { |n| if max / (scale * 1024) > 1 then scale *= 1024; label = n; else break end }
	
	# update values
	data.each_value { |v| 
	 v[:values].map! { |n| n / scale }
	 v[:keys] = v[:values].map { |n| sprintf("%6.6f #{label}", n) }
	}

    # configure graph
    options = {}#{:title => "Top Outgoing Ports", :legend => "Data Size (in KB)"}
    builder = GraphBuilder.new(:pie, data, options)
    chart = builder.build
    render :text => chart.render
  end

  #
  # Distribution of Daily Traffic by Data Size
  #
  def top_daily_by_data_size
    @group = Group.find(params[:id])
    @streams = Stream.relevant_streams(@time_range, @group, @global_rule)

	top_count = 10
	dot_size_max = 20
	dot_size_min = 5
	dot_size_range = dot_size_max - dot_size_min
	
	# initialize time information
	start_day = Time.parse(@time_range.start_time.strftime("%a %b %d 00:00:00 %Z %Y"))
	end_day = Time.parse(@time_range.end_time.strftime("%a %b %d 00:00:00 %Z %Y")) + 1.day
	days = ((end_day - start_day) / 1.day).round
	puts "DAYS: #{days}"
	start_hour = Time.parse(@time_range.start_time.strftime("%a %b %d %H:00:00 %Z %Y"))
	end_hour = Time.parse(@time_range.end_time.strftime("%a %b %d %H:00:00 %Z %Y")) + 1.hour
	hours = ((end_hour - start_hour) / 1.hour).round
	puts "HOURS: #{hours}"
	start_day_hour = @time_range.start_time.hour
	end_day_hour = @time_range.end_time.hour
	
    # initialize all data
    all_data = {}
    all_data["Data"] = Hash.new(0)
	
    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
		# find hour indexes
	    start_hour_index = ((Time.parse(window.start_time.strftime("%a %b %d %H:00:00 %Z %Y")) - start_hour) / 1.hour).round
	    end_hour_index = ((Time.parse(window.end_time.strftime("%a %b %d %H:00:00 %Z %Y")) - start_hour) / 1.hour).round
	    # sum data
	    if start_hour_index == end_hour_index
		  all_data["Data"][start_hour_index] += window.data(:all, :kilobyte)
		else
		  start_ratio = (start_hour + end_hour_index - window.start_time) / @time_range.window
		  all_data["Data"][start_hour_index] += window.data(:all, :kilobyte) * start_ratio
		  if (end_hour_index < hours)
		    all_data["Data"][end_hour_index] += window.data(:all, :kilobyte) * (1 - start_ratio)
		  end
		end
      end
    end
	
	# initialize top data: values, text, and x-axis labels
    data = {}
    data["Data"] = {
	  :values => Array.new()
	}

    temp = Array.new()
	
	# find max data value
	all_max = all_data["Data"].max{|a,b| a[1] <=> b[1]}

	# scale data
	scale = 1
	labels = %w[B KB MB GB TB PB EB]
	label = labels[0]
	labels.each { |n| if all_max[1] / (scale * 1024) > 1 then scale *= 1024; label = n; else break end }
	
	top_count.times do |i|
	  # find max
	  max = all_data["Data"].max{|a,b| a[1] <=> b[1]}
	  unless max.nil? or max.last == 0
		y = (start_day_hour + max.first) % 24
		x = start_day_hour + max.first
		data["Data"][:values].push(ScatterValue.new(x,y))
		data["Data"][:values].last.tooltip = sprintf("%6.6f #{label}",  max.last / scale)
		temp.push(max.last)
		all_data["Data"][max.first] = 0
	  end
    end

    # update dot sizes
    value_range = temp.first - temp.last

    temp.each_with_index do |x, i|
	  data["Data"][:values][i].dot_size = ((temp[i] - temp.last) / value_range) * dot_size_range + dot_size_min
	end

    # initialize chart
    chart = OpenFlashChart.new

    #title = Title.new("Scatter points")
    #chart.set_title(title)

    scatter = Scatter.new('#1C6569', dot_size_min)  # color, dot size
    scatter.values = data["Data"][:values]
    chart.add_element(scatter)

    x = XAxis.new
    x.set_range(0, days * 24, 24)
    chart.set_x_axis(x)

    y = YAxis.new
    y.set_range(0,24,4)
    chart.set_y_axis(y)

    render :text => chart.to_s
  end
end
