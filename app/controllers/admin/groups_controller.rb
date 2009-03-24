class Admin::GroupsController < AdminController
  
  def index
    # NOTE: @groups is already a variable 
    #  populated in the app/controllers/application.rb
    #  file , so you don't have to run that find again.
  end
 
  
  # GET /groups/1
  def show
    @group = Group.find(params[:id])
   
  end
 
  # GET /groups/new
  def new
    @group = Group.new
 
  end
 
  # GET /groups/1/edit
  def edit
    @gene = Gene.find(params[:id])
  end
 
  # POST /groups
  def create
    @group = group.new(params[:group])
  end
    # respond_to do |format|
      # if @gene.save
        # flash[:notice] = 'Group was successfully created.'
        # format.html { redirect_to(@group) }
        # format.xml  { render :xml => @group, :status => :created, :location => @group }
      # else
        # format.html { render :action => "new" }
        # format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      # end
    # end
  # end
 
  # PUT /group/1
  # PUT /group/1.xml
  def update
    @gene = Gene.find(params[:id])
 
    respond_to do |format|
      if @gene.update_attributes(params[:gene])
        flash[:notice] = 'Gene was successfully updated.'
        format.html { redirect_to(@gene) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @gene.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  # DELETE /genes/1
  # DELETE /genes/1.xml
  def destroy
    @gene = Gene.find(params[:id])
    @gene.destroy
 
    respond_to do |format|
      format.html { redirect_to(genes_url) }
      format.xml  { head :ok }
    end
  end
    
end
