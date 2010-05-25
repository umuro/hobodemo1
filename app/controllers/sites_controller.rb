class SitesController < ApplicationController

  hobo_model_controller
  uses_etag

  auto_actions :read_only, :except => :index

#   prepend_before_filter :fresh_on_etag,
#       :only=>[:show, :edit]
#   caches_action :show, :edit,
#       :cache_path=>:etag_cache_path.to_proc

  protected
  def show_action_etag klass
    etag = klass.etag_for(params[:id])
    #decrease resolution
    etag.merge!(:mtime=>etag[:mtime].div(5.minutes))
  end
end
