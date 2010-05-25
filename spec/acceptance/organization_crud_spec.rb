require File.dirname(__FILE__) + '/acceptance_helper'

#See 
#    https://github.com/cavalle/steak
#    https://github.com/jnicklas/capybara
#    https://github.com/thoughtbot/factory_girl

feature "Organization CRUD", %q{
  As an Admin
  I want to CRUD organizations
} do

background {@attrs = Factory.attributes_for(:organization)}

  describe "When admin, " do
    background do
      @admin = Factory(:admin)
      login_as(@admin)
    end

    describe "With nothing, " do
      describe "At list, " do
        background {visit '/organizations'}
        scenario "I browse" do
          page.should_not have_content(@attrs[:name])
        end
        scenario "I create" do
          find('.new-link.new-organization-link').click
          fill_in 'organization[name]', :with => @attrs[:name]
          click_button 'Create Organization'
          visit('/organizations')
          within('.collection.organizations .card.organization') do
            page.should have_content @attrs[:name]
          end
        end
      end
    end

    describe "With a record, " do
      background {@organization = Factory(:organization)}
      describe "At list, " do
        background {visit '/organizations'}
        scenario "I browse" do
          within('.collection.organizations .card.organization') do
            page.should have_content(@organization.name)
          end
          page.should_not have_content(@attrs[:name])
        end
        describe "At show, " do
          background do
            within('.collection.organizations .card.organization') do
              click_link @organization.name
            end
          end
          scenario "I read" do
            page.should have_content @organization.name
          end
          describe "At edit, " do
            background {find('.edit-link.organization-link').click}
            scenario "I update" do
              fill_in 'organization[name]', :with => @attrs[:name]
              click_button 'Save'
              visit('/organizations')
              within('.collection.organizations .card.organization') do
                page.should have_content @attrs[:name]
              end
            end
            scenario "I delete" do
              find('.delete-button').click
              visit('/organizations')
                page.should_not have_css('.collection.organizations .card.organization')
                page.should_not have_content(@organization.name)
            end
          end
        end
      end
    end
    
  end


#   describe "When guest, " do
#   end
    
end