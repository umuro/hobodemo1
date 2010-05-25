module Etag
module Controller

  module InstanceMethods

  protected
    def fresh_on_etag
      logger.debug "fresh_on_etag"
      fresh_when(:etag=>etag_cache_path, :public=>true)
    end

    def etag_cache_path
      model_klass = controller_name.singularize.classify.constantize
      answer = etag_cache_path_for model_klass
      logger.debug "Speeding #{answer}"
      answer
    end
    def etag_cache_path_for klass
      a = params[:action]
      et = action_etag(klass, a)
      "#{controller_name}:#{a}/#{etag_cache_path_user_granularity a}/#{etag_cache_path_page_granularity a}:#{request.format}/#{et}"
    end

    # Different actions can work at different etag granularities
    # .e.g def show_action_etag klass
    # Some pages might show multi objects while most show the subject only
    def action_etag klass, action
      special_case = action.to_s + '_action_etag'
      return send(special_case, klass) if respond_to?(special_case)
      default_action_etag klass, action
    end
    def default_action_etag klass, action
      return klass.etag_for(params[:id]) if params[:id]
      raise 'HasShowCache: default_action_etag does not handle :index actions'
    end

    # Different actions can work at different user granularities
    # .e.g def show_etag_cache_path_user_granularity
    def etag_cache_path_user_granularity action
      special_case = action.to_s + '_etag_cache_path_user_granularity'
      return send(special_case) if respond_to?(special_case)
      default_etag_cache_path_user_granularity
    end
    def default_etag_cache_path_user_granularity
      return :all unless respond_to? :current_user
      "adm:#{current_user.administrator?}"
    end

    # Different actions can work at different user granularities
    # .e.g def show_etag_cache_path_user_granularity
    # Also actions can have multi page navigation
    def etag_cache_path_page_granularity action
      special_case = action.to_s + '_etag_cache_path_page_granularity'
      return send(special_case) if respond_to?(special_case)
      default_etag_cache_path_page_granularity
    end
    def default_etag_cache_path_page_granularity
      "pg:#{params[:page] || 1}"
    end

  end

  def uses_etag
    include InstanceMethods
  end

end
end