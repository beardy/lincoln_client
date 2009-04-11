class Admin::PortNamesController < AdminController
  before_filter :get_general_params
  def index
    @port_names = PortName.find(:all, :order => 'number ASC').paginate :page => params[:page]
    respond_to do |format|
      format.html # index.html.erb
      format.js do # AJAX pagination
        render :update do |page|
          page.replace_html 'port_names', :partial => 'port_names', :locals => {:port_names => @port_names}
        end
      end
      format.xml  { render :xml => @port_names }
    end
    
  end

  def new
    @port_name = PortName.new
  end

  def edit
	  @port_name = PortName.find(params[:id])
  end
  
  def create
    @port_name = PortName.new(params[:port_name])

    respond_to do |format|
      if @port_name.save
        flash[:notice] = 'Port Association was successfully created.'
        format.html { redirect_to(admin_port_names_url) }
        format.js
        format.xml  { render :xml => @port_name, :status => :created, :location => @port_name }
      else
        flash[:notice] = 'Problem with creating new Port Association'
        format.html { render :controllers => 'admin/port_names', :action => "new" }
        format.js
        format.xml  { render :xml => @port_name.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  # PUT admin/port_name/1
  # PUT admin/port_name/1.xml
  def update
    @port_name = PortName.find(params[:id])
    respond_to do |format|
      if @port_name.update_attributes(params[:port_name])
        flash[:notice] = "#{@port_name.name} was successfully updated."
        format.html { redirect_to(admin_port_names_url(@general_params)) }
        format.js
        format.xml  { head :ok }
      else
        flash[:notice] = "Problem with updating #{@port_name.name} "
        format.html { redirect_to(admin_port_names_url(@general_params)) }
        format.js
        format.xml  { render :xml => @port_name.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  def destroy
    @port_name = PortName.find(params[:id])
    @port_name.destroy
 
    respond_to do |format|
      flash[:notice] = "#{@port_name.name} was successfully deleted."
      format.html { redirect_to(admin_port_names_url(@general_params)) }
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
