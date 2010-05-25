class UsersController < ApplicationController

  hobo_user_controller
  uses_etag

  auto_actions :all, :except => [ :index, :new, :create ]

  prepend_before_filter :fresh_on_etag,
      :only=>[:show, :edit]
  caches_action :show, :edit,
      :cache_path=>:etag_cache_path.to_proc

end
