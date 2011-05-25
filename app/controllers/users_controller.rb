class UsersController < ApplicationController

  hobo_user_controller
#   uses_etag

  auto_actions :all, :except => [:new, :create, :edit] #, :update
    
#   prepend_before_filter :fresh_on_etag,
#       :only=>[:show, :edit]
#   caches_action :show, :edit,
#       :cache_path=>:etag_cache_path.to_proc

  smart_form_setup

  def login
    hobo_login
#    hobo_login do
#      redirect_to current_user unless request.post? and current_user.is_a? ::Guest
#    end
    flash[:notice] = nil unless request.post? and current_user.is_a? ::Guest
  end
  
  
  def login_xml
    params[:login], params[:password] = params[:params][:login], params[:params][:password]
    login_was_successful = false
    hobo_login do 
      login_was_successful=true
      render end
    unless login_was_successful
      render :status=>:unauthorized end
  end
  
  def logout_xml
    hobo_logout do render end
  end
  
  def update
    @this = User.find(params[:id])
    if @this.updatable_by?(current_user)
      hobo_update
    else
      render :status => :forbidden, :text => ""
    end
  end
  
end
