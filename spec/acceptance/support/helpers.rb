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

  def enter_profile_data(profile)
    fill_in 'user_profile[first_name]', :with => profile.first_name
    fill_in 'user_profile[middle_name]', :with => profile.middle_name
    fill_in 'user_profile[last_name]', :with => profile.last_name

    select profile.gender, :from => "user_profile[gender]"

    #select @profile.birthdate.year, :from => "user_profile[birthdate][year]"
    #select @profile.birthdate.month, :from => "user_profile[birthdate][month]"
    #select @profile.birthdate.day, :from => "user_profile[birthdate][day]"
    #TODO COUNTRY
  end
  
end

Spec::Runner.configuration.include(HelperMethods)
