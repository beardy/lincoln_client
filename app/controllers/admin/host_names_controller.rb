class Admin::HostNamesController < ApplicationController
  def index
    @host_names = HostName.find(:all)
  end

  def new
  end

  def edit
  end

end
