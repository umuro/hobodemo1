set :application, "regatta-rails"
set :repository, "git@devcenter.feasiblesolutions.local:regatta_rails.git"

set :scm, "git"

set :git_enable_submodules, 1
set :deploy_to, "/var/sites/regatta-rails"
set :branch, "master"

default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true }
set :user, "deployer"
set :use_sudo, false

role :web, "web002"                          # Your HTTP server, Apache/etc
role :app, "web002"                          # This may be the same as your `Web` server
role :db,  "web002", :primary => true # This is where Rails migrations will run

set :deploy_via, :remote_cache

require 'config/deploy_application'

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end