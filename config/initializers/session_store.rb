# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_regatta_rails_session',
  :secret      => 'd9c4522c532fd8d42b428432fdbf72e5dcf0568e3b9cb8044be3d2c47dd68d4ced93b968b55bb4adacad08ffb5e385b99e838662c1e09cb323fa4c6385c04049'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
