class RulesController < ApplicationController
  def update
    if(params[:rule][:id] == 'global')
      @global_rule = Rule.new(params[:rule])
      redirect_to :controller => :groups, :action => :index
    end
  end
end
