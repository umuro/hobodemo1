#lib/tasks/app_populate.rake
namespace :app do
 
desc 'Fill database with test data'
task :populate => [:environment, "db:reset"] do
  require 'factory_girl'
  Dir['test/factories/*.rb'].each { |f| require f[0..-4] }
  
  p "Manifacturing Objects..."
  
  Factory(:admin, :email_address=>'admin@test.com')
  organization_admin = Factory(:user, :email_address=>'organization_admin@test.com' )
  Factory(:user)
  
  boat = UseCaseSamples.build_boat 
  race = UseCaseSamples.build_race 
  UseCaseSamples.participate_to_race_fleet :boat => boat, :race => race
  
  race.organization.organization_admins << organization_admin
end
 
end