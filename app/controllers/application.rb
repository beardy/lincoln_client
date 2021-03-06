# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  before_filter :find_groups, :get_time_range, :get_global_rule, :get_selected_groups
  
  # This will be used to show all groups 
  # In the nav bar
  def find_groups
    @groups ||= Group.find(:all)
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
  

  def get_time_range
    @time_range = session[:time_range] ||= TimeRange.new
  end  
  
  def get_global_rule
    @global_rule = session[:global_rule] ||= Rule.new
  end
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '57e4b2474d2fe510397fc865730f56c8'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
end
