class Admin::GroupsController < AdminController
  
  def index
    # NOTE: @groups is already a variable 
    #  populated in the app/controllers/application.rb
    #  file , so you don't have to run that find again.
	respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @group }
    end
  end
 
  
  # GET admin/groups/1
  def show
    @group = Group.find(params[:id])
   
  end
 
  # GET admin/groups/new
  def new
    @group = Group.new
 
  end
 
  # GET admin/groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end
 
  # POST admin/groups
  def create
    @group = Group.new(params[:group])

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(@group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  # PUT admin/group/1
  # PUT admin/group/1.xml
  def update
    @group = Group.find(params[:id])
 
    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  # DELETE /group/1
  def destroy
    @group = Group.find(params[:id])
    @group.destroy
 
    respond_to do |format|
      format.html { redirect_to(index) }
      format.xml  { head :ok }
    end
  end
    
end
