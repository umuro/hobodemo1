# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')


Rails::Initializer.run do |config|
  config.gem 'hobo'
  # config.gem 'acts_as_list'
  # config.gem 'capistrano'
  config.gem 'haml'
  config.gem 'builder'
  #config.gem 'bluecloth' 
  #config.gem 'rdiscount' 
  config.gem 'memcached-northscale', :lib => 'memcached'

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  config.i18n.default_locale = :en

  require 'memcached'
  config.cache_store = :mem_cache_store, Memcached::Rails.new
  
#   unless "RAILS_ENV" == "production"
#     require 'rack/cache'
#     config.gem 'rack-cache'
#     config.middleware.use Rack::Cache,
#       :verbose => true,
#       :metastore   => 'file:/tmp/cache/rack/meta',
#       :entitystore => 'file:/tmp/cache/rack/body'
#     # I am deploying to Heroku
#     # Heroku has Varnish which replaces rack-cache
#     # The purpose is to have caching in test and development
#   end
end
