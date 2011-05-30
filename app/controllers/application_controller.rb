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
  before_filter :keep_referer
  
  attr_reader :iframe_mode
  
  def iframe_domain
    @iframe_mode = false
    host = request.env['HTTP_HOST'] ? request.env['HTTP_HOST'] : 'localhost'
    @iframe_mode = true if (host.partition('.').first == 'widgets') && (!request.xhr?)
    params[:widget] = 'framed' if @iframe_mode
  end

  private
  def keep_referer
    if request.method == :get
      logger.info request.env['HTTP_REFERER']
      begin
	old_path = ActionController::Routing::Routes.recognize_path URI.parse(request.env['HTTP_REFERER']).path
	session['HTTP_REFERER'] = request.env['HTTP_REFERER'] unless old_path[:controller] == 'users'
      rescue
      end
    end
    true
  end

  def self.smart_form_setup
    if private_method_defined?(:hobo_login) and not private_method_defined?(:orig_hobo_login)
      alias_method :orig_hobo_login, :hobo_login
      define_method(:hobo_login) { |&b|
        orig_hobo_login :redirect_to=>session['HTTP_REFERER'], &b
      }
    end

    if instance_methods.include?('hobo_update') and not instance_methods.include?('orig_hobo_update')
      alias_method :orig_hobo_update, :hobo_update
      define_method(:hobo_update) { |*args, &b|
        orig_hobo_update :redirect=>session['HTTP_REFERER'], &b
      }
    end

    if instance_methods.include?('hobo_create_for') and not instance_methods.include?('orig_hobo_create_for')
      alias_method :orig_hobo_create_for, :hobo_create_for
      define_method(:hobo_create_for) { |owner_association, *args, &b|
        orig_hobo_create_for owner_association, :redirect=>session['HTTP_REFERER'], &b
      }
    end
  end

end
