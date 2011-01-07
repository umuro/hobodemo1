#lib/tasks/app_populate.rake
namespace :app do
 
  desc 'Fill database with countries'
  task :country_seed => [:environment] do
    CountrySeed.instance.perform
  end
 
end
