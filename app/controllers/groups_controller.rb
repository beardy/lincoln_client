class GroupsController < ApplicationController
  
  
  # GET /gene_groups
  # GET /gene_groups.xml
  def index
    @groups = Group.find(:all)
	
    # Here's the basic use of the starting_between named scope
    # =>  @streams = Stream.starting_between(@start_time, @end_time)
    # Here's how we can use it with the built in finds for more granularity
    #  so w're using the starting_between to scope the results, then the find
    #  to get a specific subset of that. Its beautiful!
    @streams = Stream.starting_between(@start_time, @end_time).find(:all, :conditions => rule_string)
    
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
  	@graph1 = open_flash_chart_object(500,300,url_for(:action => "packet_size", :id => @group.id))
  	@graph2 = open_flash_chart_object(500,300,"/graphs/packet_count_inc_vs_out")

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
    
  def update_time_range
    @time_range.update(params[:name], params[:date])
    # session[params[:name].to_sym] = Time.zone.parse(params["date"])
    render :layout => false
  end
  
end
