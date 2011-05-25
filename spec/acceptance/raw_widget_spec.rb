require File.dirname(__FILE__) + '/acceptance_helper'

#See 
#    https://github.com/cavalle/steak
#    https://github.com/jnicklas/capybara
#    https://github.com/thoughtbot/factory_girl

feature "Raw Widget Spec", %q{
  As a webbrowser, I want to know whether the given url widgets and ajax calls are getting
  the proper response.
} do
  
  background do
    Factory :event
    @admin = Factory :admin
    login_as @admin
  end

  describe "For any given user, " do
    scenario "I want to have a widget display" do
      visit 'http://widgets.example.com/'
      page.should have_no_selector '.page-header'
      page.body.rstrip[-7..-1].should == '</html>'
    end

    scenario "I want to have a divisioned display" do
      page.driver.get '/', nil, {:xhr => true} 
      # Somehow the html selector is not supported, falling back on string matching
      page.body.lstrip[0..4].should == '<div>'
      page.body.rstrip[-6..-1].should == '</div>'
    end
    
    scenario "I want to have a normal display" do
      visit '/'
      page.should have_selector '.page-header'
      page.body.rstrip[-7..-1].should == '</html>'
    end
  end 
end
