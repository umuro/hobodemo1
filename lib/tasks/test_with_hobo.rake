task :test => 'hobo:generate_taglibs'
namespace :test do
  task :functionals => 'hobo:generate_taglibs'
end
