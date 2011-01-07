require File.dirname(__FILE__) + '/acceptance_helper'

#See 
#    https://github.com/cavalle/steak
#    https://github.com/jnicklas/capybara
#    https://github.com/thoughtbot/factory_girl


feature "UserProfile CRUD", %q{
  As a user I want to 
  create, read and update my profile
} do

  describe "When a user" do

    background {
      @user = Factory(:user)
      @profile = Factory(:user_profile)
      login_as @user
    }

    describe "with no profile" do

      describe "visits his account page" do

        background {
          visit "/"
          click_link "Account"
        }

#         scenario "enters data and creates his profile" do
#           page.should have_content("Create your user profile")
#           enter_profile_data(@profile)
#           click_button "Create User Profile"
#           page.should have_content("The user profile was created successfully")
#         end

      end
    end

    describe "with a profile" do

      background {
        @user.user_profiles << @profile
      }
      
      describe "visits his account page" do

        background {
          visit "/"
          click_link "Account"
        }

# #         scenario "account page" do
# #           page.should have_content("Account Details")
# #           within('.section.with-flash.content') do
# #             find('.edit-link.user-profile-link')
# #             page.should have_content(@profile.first_name)
# #             page.should have_content(@profile.middle_name)
# #             page.should have_content(@profile.last_name)
# #             page.should have_content(@profile.birthdate.to_s)
# #             page.should have_content(@profile.country.to_s)
# #           end
# # 
# #         end

#         describe "edits his profile data" do
# 
#           background {
#             click_link "Edit User Profile"
#           }
# 
#           scenario "changes his middle name" do
#             fill_in 'user_profile[middle_name]', :with => "new middle name"
#             click_button 'Save'
#             page.should have_content("new middle name")
#           end
# 
#         end

      end
    end

  end

  describe "When an admin" do

    background {
      @admin = Factory(:admin)
      login_as @admin
    }

    #TODO

  end
end