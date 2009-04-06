class Admin::RulesController < AdminController
  
  # GET admin/rules/new
  def new
    @rule = Rule.new
	  redirect_to :controller => 'admin/groups', :action => 'index'
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
        format.html { redirect_to :controller => 'admin/groups', :action => 'index' }
        format.xml  { render :xml => @rule, :status => :created, :location => @rule }
        format.js
      else
        format.html { redirect_to :controller => 'admin/groups', :action => 'index' }
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
