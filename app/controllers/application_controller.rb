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
  before_filter :keep_redirect
  before_filter :force_user_profile
  around_filter :keep_referer
  
  attr_reader :iframe_mode
  
  def iframe_domain
    @iframe_mode = false
    host = request.env['HTTP_HOST'] ? request.env['HTTP_HOST'] : 'localhost'
    @iframe_mode = true if (host.partition('.').first == 'widgets') && (!request.xhr?)
    params[:widget] = 'framed' if @iframe_mode
  end
 
  private
  #TEST spec if user without profile is forced to edit returning to desired place
  def keep_redirect
    return unless request.method == :get
    #FORM posts will return to this address later
    # You can now pass to form urls where you want them to return
    if params[:redirect]
      session['HTTP_REFERER'] = params[:redirect]
      session[:keep_referrer] = true
    end
#     logger.info "KEEP REDIRECT #{session['HTTP_REFERER']}"
  end
  
  def force_user_profile
    if current_user.signed_up? and
	not current_user.administrator? and
	current_user.user_profile.blank? and
	request.method == :get and
	request.request_uri[new_user_profile_path].nil? and
	request.request_uri[user_path(current_user)+'/'].nil?
      raise "debug" if request.request_uri[new_user_profile_path]
      prof = UserProfile.new :owner_id=>current_user.id
      redirect_to new_user_profile_path(prof, :redirect=>request.request_uri )
     end
  end

  def std_form_actions url_params
    url_params[:action] == 'new' or url_params[:action].start_with?('new_for_') or
        url_params[:action] == 'edit' or self.class.instance_methods.include?('do_'+url_params[:action])
  end

  def ignored_urls url_params
    users_action = (url_params[:controller] == 'users' and url_params[:action] != 'show')
    if session['forms_req']
      users_action or request.env['HTTP_REFERER'] == session['forms_req']
    else
      users_action
    end
  end

  def keep_referer
    req = request.env['action_controller.request.path_parameters']
    req_url = url_for(req)
    begin
      ref = ActionController::Routing::Routes.recognize_path URI.parse(request.env['HTTP_REFERER']).path,:method=>:get
    rescue
    end
    logger.debug "KEEP_REFERER req #{req} req_url #{req_url} ref #{ref}"
    if session[:keep_referrer] and (ref == nil or req_url == session['HTTP_REFERER']) # form sequence cancelled
      session.delete(:keep_referrer)
      params[:keep_referrer] = nil
    end
    logger.debug "KEEP_REFERER request.env['HTTP_REFERER'] #{request.env['HTTP_REFERER']}" if request.env['HTTP_REFERER']
    logger.debug "KEEP_REFERER ignored_urls(ref) #{ref && ignored_urls(ref)}, std_form_actions(ref) #{ref && std_form_actions(ref)}" if ref
    if session[:keep_referrer] == nil and ref != nil and not ignored_urls(ref) and not std_form_actions(ref)
      session['HTTP_REFERER'] = request.env['HTTP_REFERER']
    end
    if params[:keep_referrer]
      session[:keep_referrer] = true
    end
    logger.debug "KEEP_REFERER session['HTTP_REFERER'] #{session['HTTP_REFERER']}" if session['HTTP_REFERER']
    begin
      yield
    rescue
    end
    if request.method != :get
      if @performed_redirect
        if response.location == session['HTTP_REFERER']
          session.delete('HTTP_REFERER')
          session.delete(:keep_referrer)
          session.delete('forms_req')
        end
      else #post/put without redirect, means re-display form 
        session['forms_req'] = req_url
      end
    end
  end

  def self.smart_form_setup
    if private_method_defined?(:hobo_login) and not private_method_defined?(:orig_hobo_login)
      alias_method :orig_hobo_login, :hobo_login
      define_method(:hobo_login) { |&b|
        orig_hobo_login :redirect_to=>session['HTTP_REFERER'], &b
      }
    end

    if instance_methods.include?('hobo_create') and not instance_methods.include?('orig_hobo_create')
      alias_method :orig_hobo_create, :hobo_create
      define_method(:hobo_create) { |*args, &b|
        orig_hobo_create :redirect=>session['HTTP_REFERER'], &b
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

    if instance_methods.include?('do_creator_action') and not instance_methods.include?('orig_do_creator_action')
      alias_method :orig_do_creator_action, :do_creator_action
      define_method(:do_creator_action) { |name, *params, &b|
        orig_do_creator_action name, :redirect=>session['HTTP_REFERER'], &b
      }
    end

    if instance_methods.include?('do_transition_action') and not instance_methods.include?('orig_do_transition_action')
      alias_method :orig_do_transition_action, :do_transition_action
      define_method(:do_transition_action) { |name, *params, &b|
        orig_do_transition_action name, :redirect=>session['HTTP_REFERER'], &b
      }
    end
  end#smart_form_setup

  def render_csv(filename = nil)
    filename ||= params[:action]
    filename += '.csv'

    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Expires'] = "0"
    end
    headers["Content-Type"] ||= 'application/vnd.ms-excel'
    headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""

    render :layout => false
  end#render_csv
  
end#class
