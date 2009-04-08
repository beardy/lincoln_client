class Admin::RulesController < AdminController
  
  # GET admin/rules/new
  def new
    @rule = Rule.new
	  redirect_to :controller => 'admin/groups', :action => 'index'
  end
 
  def edit
    @rule = Rule.find(params[:id])
  end
 
  def create
    @rule = Rule.new(params[:rule])

    respond_to do |format|
      if @rule.save
        # flash[:notice] = 'Rule was successfully created.'
        format.html { redirect_to :controller => 'admin/groups', :action => 'index' }
        format.xml  { render :xml => @rule, :status => :created, :location => @rule }
        format.js
      else
        format.html { redirect_to :controller => 'admin/groups', :action => 'index' }
        format.xml  { render :xml => @rule.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end
 
  def update
    @rule = Rule.find(params[:id])
 
    respond_to do |format|
      if @rule.update_attributes(params[:rule])
        # flash[:notice] = 'rule was successfully updated.'
        format.html {  redirect_to :controller => 'admin/groups', :action => 'index'  }
        format.xml  { head :ok }
        format.js
      else
        format.html { redirect_to :controller => 'admin/groups', :action => 'index'  }
        format.xml  { render :xml => @rule.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end
 
  def destroy
    puts "----DESTROY CALLED----"
    @rule = Rule.find(params[:id])
    @rule.destroy
 
    respond_to do |format|
      format.html { redirect_to :controller => 'admin/groups', :action => 'index' }
      format.xml  { head :ok }
      format.js
    end
  end
    
end
