class RulesController < ApplicationController
  def update
    puts params.inspect
    if(params[:rule][:id] == 'global')
      session[:global_rule] = Rule.new(params[:rule])
      puts session[:global_rule].inspect
      redirect_to :controller => :groups, :action => :index
    end
  end
  
  def clear_global_rule
    session[:global_rule] = Rule.new()
    respond_to do |format|
      format.html
      format.js
    end
  end
end
