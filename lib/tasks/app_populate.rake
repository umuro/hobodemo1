#lib/tasks/app_populate.rake
namespace :app do
 
desc 'Fill database with test data'
task :populate => [:environment, "db:reset", "app:country_seed"] do
  require 'factory_girl'
  Dir['test/factories/*.rb'].each { |f| require f[0..-4] }
  
  p "Manifacturing Objects..."
  
  Factory(:admin, :email_address=>'admin@test.com')
  organization_admin = Factory(:user, :email_address=>'organization_admin@test.com' )

  #Somebody enrolls an event  
  u = Factory(:user)
  boat = UseCaseSamples.build_boat :owner=>u
  fleet_race = UseCaseSamples.build_fleet_race 
#   UseCaseSamples.participate_to_race_fleet :boat => boat, :race => race
  fleet_race.organization.organization_admins << organization_admin


  #More users around
  (1..50).each { Factory(:user) } #Misc users around  
end
 
end
