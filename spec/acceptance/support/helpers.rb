module HelperMethods
  # Put here any helper method you need to be available in all your acceptance tests
  
  def logger
    Rails::logger
  end

  def login_as(user)
    visit '/login'
    fill_in 'login', :with => user.email_address
    fill_in 'password', :with => user.password
    click_button 'Log in'
  end

end

Spec::Runner.configuration.include(HelperMethods)
