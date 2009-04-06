class Admin::PortNamesController < ApplicationController
  def index
    @port_names = PortName.find(:all).paginate :page => params[:page]
  end

  def new
  end

  def edit
	@port_name = PortName.find(params[:id])
  end

end
