class GraphsController < ApplicationController
  
  def packet_size_inc_vs_out
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find_all_by_port_incoming(80)
    #
    # initialize data
    #
    inc_data = Array.new(@time_range.ticks, 0)
    out_data = Array.new(@time_range.ticks, 0)
  
    # for each stream & window
    @streams.each do |stream|
      stream.windows.each do |window|
      
        # for each tick
        @time_range.each_tick_with_time do |tick, tick_time|
          # if within tick range, add data
          if window.between?(tick_time)
            inc_data[tick] += window.data(:incoming, :kilobyte) * @time_range.ratio
            out_data[tick] += window.data(:outgoing, :kilobyte) * @time_range.ratio
          end
        end

      end
    end
	
  # inc_data.collect! {|x| x / 1024} # convert to KB
  # out_data.collect! {|x| x / 1024} # convert to KB
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
    @streams = Stream.starting_between(@time_range.start_time, @time_range.end_time).find_all_by_port_incoming(80)
  
  
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

    render :text => chart.to_s
  end
  

end
