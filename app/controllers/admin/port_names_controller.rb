class Admin::PortNamesController < ApplicationController
  def index
    @port_names = PortName.find(:all)
  end

  def new
  end

  def edit
  end

end
