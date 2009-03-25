class Admin::RulesController < AdminController
  
  def index
    # NOTE: @groups is already a variable 
    #  populated in the app/controllers/application.rb
    #  file , so you don't have to run that find again.
	respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rule }
    end
  end
 
  
  # GET admin/rules/1
  def show
    @rule = Rule.find(params[:id])
   
  end
 
  # GET admin/rules/new
  def new
    @rule = Rule.new
	
	respond_to do |format|
      render "admin/groups/index.html.erb"
    end
  end
 
  # GET admin/groups/1/edit
  def edit
    @rule = Rule.find(params[:id])
  end
 
  # POST admin/groups
  def create
    @rule = Rule.new(params[:rule])

    respond_to do |format|
      if @rule.save
        flash[:notice] = 'Rule was successfully created.'
        format.html { redirect_to(@rule) }
        format.xml  { render :xml => @rule, :status => :created, :location => @rule }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rule.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  # PUT admin/group/1
  # PUT admin/group/1.xml
  def update
    @rule = Rule.find(params[:id])
 
    respond_to do |format|
      if @rule.update_attributes(params[:rule])
        flash[:notice] = 'rule was successfully updated.'
        format.html { redirect_to(@rule) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rule.errors, :status => :unprocessable_entity }
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
