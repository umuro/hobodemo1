desc "This task is called by the Heroku cron add-on"
task :cron => [:environment, "app:country_seed"]
