require 'capybara/envjs'
#Capybara.javascript_driver = :envjs

Spec::Runner.configure do |config|

  config.before(:each) do
    Capybara.current_driver = :envjs if options[:js]
  end

  config.after(:each) do
    Capybara.use_default_driver if options[:js]
  end

end

