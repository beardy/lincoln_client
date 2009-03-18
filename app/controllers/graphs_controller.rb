class GraphsController < ApplicationController
  before_filter :get_time_range
  
  def packet_size_inc_vs_out
    @streams = Stream.starting_between(@start_time, @end_time).find_all_by_port_incoming(80)
  
    # initialize graphing parameters
    graph_ticks = 15
    window_size = 5.minutes
    time_range = @end_time - @start_time
    time_increment = time_range / graph_ticks
    tick_ratio = time_increment / window_size
  
    #
    # initialize data
    #
    inc_data = Array.new(graph_ticks, 0)
    out_data = Array.new(graph_ticks, 0)
  
    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
      
        # for each tick
        graph_ticks.times do |i|
          tick_time = @start_time + (i * time_increment)
    
          # if within tick range, add data
          if window.start_time <= tick_time and window.end_time >= tick_time
            inc_data[i] += window.size_packets_incoming * tick_ratio
            out_data[i] += window.size_packets_outgoing * tick_ratio
          end
        end

      end
    end
	
	inc_data.collect! {|x| x / 1024} # convert to KB
	out_data.collect! {|x| x / 1024} # convert to KB
	#out_data = out_data.zip(inc_data).map{|x, y| x + y} # convert to stacked line graph
	
    #
    # initialize graph
    #
    title = Title.new("Packet Size - Incoming vs. Outgoing")
    
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

    y_legend = YLegend.new("Packet Data in KB")
    y_legend.set_style('{font-size: 20px; color: #770077}')


    chart = OpenFlashChart.new
    chart.set_title(title)
    #chart.set_x_legend(x_legend)
    chart.set_y_legend(y_legend)
    #chart.x_axis = x
    chart.y_axis = y

    chart.add_element(line_inc)
    chart.add_element(line_out)

    render :text => chart.to_s
  end
  
  def packet_count_inc_vs_out
    @streams = Stream.starting_between(@start_time, @end_time).find_all_by_port_incoming(80)
  
    # initialize graphing parameters
    graph_ticks = 15
    window_size = 5.minutes
    time_range = @end_time - @start_time
    time_increment = time_range / graph_ticks
    tick_ratio = time_increment / window_size
  
    #
    # initialize data
    #
    inc_data = Array.new(graph_ticks, 0)
    out_data = Array.new(graph_ticks, 0)
  
    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
      
        # for each tick
        graph_ticks.times do |i|
          tick_time = @start_time + (i * time_increment)
    
          # if within tick range, add data
          if window.start_time <= tick_time and window.end_time >= tick_time
            inc_data[i] += window.num_packets_incoming * tick_ratio
            out_data[i] += window.num_packets_outgoing * tick_ratio
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

    render :text => chart.to_s
  end
  
  # This method will eventually be tied to the date picker to 
  #  allow for changing the current start and stop times
  def get_time_range
    @start_time = session[:start_date_time] ||= 2.days.ago
    @end_time = session[:end_date_time] ||=  Time.now
  end

end
