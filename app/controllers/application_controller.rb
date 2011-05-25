# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password if Rails.env.production?
  filter_parameter_logging :password if Rails.env.production?

  # This is done for the verification of iframe widgets versus normal widgets
  before_filter :iframe_domain
  
  attr_reader :iframe_mode
  
  def iframe_domain
    @iframe_mode = false
    host = request.env['HTTP_HOST'] ? request.env['HTTP_HOST'] : 'localhost'
    @iframe_mode = true if (host.partition('.').first == 'widgets') && (!request.xhr?)
    params[:widget] = 'framed' if @iframe_mode
  end
end
