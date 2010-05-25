unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end

Capistrano::Configuration.instance.load do

  namespace :application do

    desc <<-DESC
      Installs the requered gems.

    DESC
    task :gems_install, :except => { :no_release => true } do
      run "cd  #{release_path};rake gems:install"
    end

    desc <<-DESC
      Creates the symbolic links and application specifig configurations..


      When this recipe is loaded, watch_it:setup is automatically configured \
      to be invoked after deploy:setup. You can skip this task setting \

    DESC
    task :setup, :except => { :no_release => true } do
      run "mkdir -p #{shared_path}/clip"
      run "mkdir -p #{shared_path}/sitemaps"
      run "touch #{shared_path}/database.yml"
      run "gem install extlib"
      run "gem install builder"
      run "gem install alexrabarts-big_sitemap -s http://gems.github.com"
      run "gem install cached_model"
      run "gem install SystemTimer"
    end

    desc <<-DESC
      [internal] Updates the symlink for database.yml file to the just deployed release.
    DESC
    task :symlink, :except => { :no_release => true } do
      run "ln -nfs #{shared_path}/database.yml #{release_path}/config/database.yml"
      run "rm -Rf #{release_path}/public/clip"
      run "ln -nfs #{shared_path}/clip #{release_path}/public/clip"
      run "ln -nfs #{shared_path}/sitemaps #{release_path}/public/sitemaps"
    end

  end #namespace

  after "deploy:setup",           "application:setup"
  after "deploy:finalize_update", "application:symlink"
  after "deploy:finalize_update", "application:gems_install"

end