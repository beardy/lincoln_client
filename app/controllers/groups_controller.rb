class GroupsController < ApplicationController
  before_filter :get_time_range
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
    @start_time = 1.day.ago.to_formatted_s(:db)
    @end_time = 1.hour.from_now.to_formatted_s(:db)
  end
  
end
