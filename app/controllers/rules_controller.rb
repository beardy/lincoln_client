class RulesController < ApplicationController
  def update_global_rule
    if(params[:rule][:id] == 'global')
      session[:global_rule] = Rule.new(params[:rule])
      respond_to do |format|
        format.html
        format.js
      end
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
