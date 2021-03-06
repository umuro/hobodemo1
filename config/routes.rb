ActionController::Routing::Routes.draw do |map|

  map.login_xml 'login_xml', :controller => 'users', :action=> 'login_xml', :format=>'xml'
  map.logout_xml 'logout_xml', :controller => 'users', :action=> 'logout_xml', :format=>'xml'

  map.site_search  'search', :controller => 'front', :action => 'search'
#   map.root :controller => 'front', :action => 'index'
  map.root :controller => 'sites', :action => 'show', :id=>'1'

  Hobo.add_routes(map)
  
  # FIXME: Hobo can't deal with auto_actions_for defined on STI models. Therefore, some routes are missing
  map.new_spot_for_template_course 'template_courses/:course_id/spots/new', :controller => :spots, :action => :new_for_course, :conditions => {:method => :get}
  map.create_spot_for_template_course 'template_courses/:course_id/spots', :controller => :spots, :action => :create_for_course, :conditions => {:method => :post}
  map.spots_for_template_course 'template_courses/:course_id/spots', :controller => :spots, :action => :index_for_course, :conditions => {:method => :get}
    
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
