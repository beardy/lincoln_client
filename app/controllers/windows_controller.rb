class WindowsController < ApplicationController


  def index

  end

  def show
    # TODO : This also needs to be seperated by groups?
    @stream = Stream.find(params[:id])
  end


end