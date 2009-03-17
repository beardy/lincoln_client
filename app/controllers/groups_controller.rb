class GroupsController < ApplicationController
  before_filter :get_time_range, :except => [:update_time_range]
  # GET /gene_groups
  # GET /gene_groups.xml
  def index
    @groups = Group.find(:all)
    # Here's the basic use of the starting_between named scope
    # =>  @streams = Stream.starting_between(@start_time, @end_time)
    # Here's how we can use it with the built in finds for more granularity
    #  so w're using the starting_between to scope the results, then the find
    #  to get a specific subset of that. Its beautiful!
    @streams = Stream.starting_between(@start_time, @end_time).find_all_by_port_incoming(80)
    
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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end
  
  # This method will eventually be tied to the date picker to 
  #  allow for changing the current start and stop times
  def get_time_range
    @start_time = session[:start_date_time] ||= 1.minute.ago
    @end_time = session[:end_date_time] ||=  2.days.ago
  end
  
  def update_time_range
    session[:start_date_time]
    session[params[:name].to_sym] = Time.zone.parse(params["date"])
    render :layout => false
  end
  
end
