task :test => 'spec:acceptance'
namespace :spec do
  task :acceptance => 'hobo:generate_taglibs'
end