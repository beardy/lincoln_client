class Admin::HostNamesController < AdminController
  before_filter :get_general_params
  def index
    @host_names = HostName.find(:all, :order => 'raw_ip_address ASC').paginate :page => params[:page]
    respond_to do |format|
      format.html # index.html.erb
      format.js do # AJAX pagination
        render :update do |page|
          page.replace_html 'host_names', :partial => 'host_names', :locals => {:host_names => @host_names}
        end
      end
      format.xml  { render :xml => @host_names }
    end
    
  end

  def new
    @host_name = HostName.new
  end

  def edit
	  @host_name = HostName.find(params[:id])
  end
  
  def create
    @host_name = HostName.new(params[:host_name])

    respond_to do |format|
      if @host_name.save
        flash[:notice] = 'Host Association was successfully created.'
        format.html { redirect_to(admin_host_names_url) }
        format.js
        format.xml  { render :xml => @host_name, :status => :created, :location => @host_name }
      else
        format.html { render :controllers => 'admin/host_names', :action => "new" }
        format.js
        format.xml  { render :xml => @host_name.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  # PUT admin/host_name/1
  # PUT admin/host_name/1.xml
  def update
    @host_name = HostName.find(params[:id])
    respond_to do |format|
      if @host_name.update_attributes(params[:host_name])
        flash[:notice] = "#{@host_name.name} was successfully updated."
        format.html { redirect_to(admin_host_names_url(@general_params)) }
        format.js
        format.xml  { head :ok }
      else
        flash[:notice] = "Problem with updating #{@host_name.name} "
        format.html { redirect_to(admin_host_names_url(@general_params)) }
        format.js
        format.xml  { render :xml => @host_name.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  def destroy
    @host_name = HostName.find(params[:id])
    @host_name.destroy
 
    respond_to do |format|
      flash[:notice] = "#{@host_name.name} was successfully deleted."
      format.html { redirect_to(admin_host_names_url(@general_params)) }
      format.xml  { head :ok }
      format.js
    end
  end
  
  def get_general_params
    @general_params = {}
    @general_params = {:page => params[:page]} unless params[:page].blank?
    @general_params
  end

end
