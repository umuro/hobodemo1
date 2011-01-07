ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'config/initializers/inflections'

# Webrat.configure do |config|
#   config.mode = :rails
#   #http://gitrdoc.com/rdoc/brynary/webrat/273e8c541a82ddacf91f4f68ab6166c16ffdc9c5/classes/Webrat/Configuration.html
# end
 
class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = false
 
  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false
 
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all
 
  # Add more helper methods to be used by all tests here...
  class << self
    def could do_sth
      puts "Could #{do_sth}"
    end
    alias feature context
  end
 
  def cleanup
#     prev_level = ActiveRecord::Base.logger.level
#     ActiveRecord::Base.logger.level = Logger::INFO
#     ActiveRecord::Base.delete_everything!
#     ActiveRecord::Base.logger.level = prev_level
  end
 
  require 'database_cleaner'
  DatabaseCleaner.strategy = :transaction
  def setup; super; DatabaseCleaner.start; end
  def teardown; DatabaseCleaner.clean; super; end
end
 
class ActionController::TestCase
  #http://alexbrie.net/1526/functional-tests-with-login-in-rails/
  #   def login_as(user)
  #     @request.session[:user] = user ? user.id : nil
  #   end

  #http://alexbrie.net/1526/functional-tests-with-login-in-rails/
  def login_as(user)
    old_controller = @controller
    @user_controller = UsersController.new
    @controller = @user_controller
    post :login, :login => user.email_address, :password => user.password
    assert_response :found
    @controller = old_controller
  end

  def logout
    @user_controller.logout if @user_controller
  end

end
 
module Rack
  module Utils
    class HeaderHash
      puts "Rack::Utils::HeaderHash bug fix on #replace"

      def replace other
        self.clear
        other.each  { |k,v| self[k] = v }
      end
    end
  end
end