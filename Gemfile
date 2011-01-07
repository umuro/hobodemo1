source "http://rubygems.org/"

gem "rails",                "=2.3.11"
gem "hobo",                 "=1.0.2"
gem "sass",                 ">=3.1.1"
gem "will_paginate",        ">=2.3.11"
gem "dalli"
gem "builder"
gem "tzinfo"
gem "system_timer"
gem "nokogiri"
gem "redis-namespace"
gem "redis"
gem "resque", :require => 'resque/server'
gem "redis-mutex"
gem "thor"
gem "htmlentities"

gem "sqlite3", :groups => [:test, :development]

group :test do
  gem "factory_girl"
  gem "shoulda"
  gem "mocha"
  gem "rspec",              "= 1.3.1",  :require => nil
  gem "rspec-rails",        "= 1.3.3",  :require => nil
  gem "steak"
  gem "capybara"
  gem  "delorean" #Change Time.now in tests
  gem  "database_cleaner" #Remove data
  gem  "spork",		"~> 0.9.0.rc4"
  gem  "autotest-rails"
  gem  "redgreen"
  gem  "test_notifier"
end

gem 'ruby-debug', :groups => [:test, :development]
